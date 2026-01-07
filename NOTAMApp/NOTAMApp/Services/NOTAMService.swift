import Foundation

/// Service for fetching NOTAMs from the FAA API
actor NOTAMService {
    static let shared = NOTAMService()

    private let baseURL = "https://notams.aim.faa.gov/notamSearch/search"
    private let session: URLSession

    private let maxRetries = 3
    private let retryDelays: [TimeInterval] = [1.0, 2.0, 4.0] // Exponential backoff

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Public API

    /// Fetches NOTAMs for a list of FIR/location codes
    func fetchNOTAMs(for locations: [String]) async throws -> [String: [NOTAM]] {
        var results: [String: [NOTAM]] = [:]
        var errors: [String: Error] = [:]

        await withTaskGroup(of: (String, Result<[NOTAM], Error>).self) { group in
            for location in locations {
                group.addTask {
                    do {
                        let notams = try await self.fetchNOTAMs(for: location)
                        return (location, .success(notams))
                    } catch {
                        return (location, .failure(error))
                    }
                }
            }

            for await (location, result) in group {
                switch result {
                case .success(let notams):
                    results[location] = notams
                case .failure(let error):
                    errors[location] = error
                }
            }
        }

        if results.isEmpty && !errors.isEmpty {
            throw NOTAMError.allFetchesFailed(errors)
        }

        return results
    }

    /// Fetches NOTAMs for a single location with retry logic
    func fetchNOTAMs(for location: String) async throws -> [NOTAM] {
        var lastError: Error?

        for attempt in 0..<maxRetries {
            do {
                return try await performFetch(for: location)
            } catch let error as NOTAMError {
                // Don't retry on non-transient errors
                if case .invalidResponse = error { throw error }
                if case .apiError = error { throw error }
                lastError = error
            } catch {
                lastError = error
            }

            if attempt < maxRetries - 1 {
                try await Task.sleep(nanoseconds: UInt64(retryDelays[attempt] * 1_000_000_000))
            }
        }

        throw lastError ?? NOTAMError.unknown
    }

    // MARK: - Private

    private func performFetch(for location: String) async throws -> [NOTAM] {
        let request = try buildRequest(for: location)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NOTAMError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            return try parseResponse(data)
        case 429:
            throw NOTAMError.rateLimited
        case 400..<500:
            throw NOTAMError.apiError(statusCode: httpResponse.statusCode, message: nil)
        case 500..<600:
            throw NOTAMError.serverError
        default:
            throw NOTAMError.invalidResponse
        }
    }

    private func buildRequest(for location: String) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL) else {
            throw NOTAMError.invalidURL
        }

        // The FAA NOTAM API uses POST with form data
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Build the request body
        let params: [String: String] = [
            "searchType": "0",
            "designatorsForLocation": location,
            "notamType": "",
            "flightPathBuffer": "10",
            "flightPathIncludeNavaids": "true",
            "flightPathIncludeArtcc": "false",
            "flightPathIncludeTfr": "true",
            "flightPathIncludeRegulatory": "false",
            "flightPathResultsType": "0",
            "archiveDate": "",
            "archiveDesignator": "",
            "offset": "0",
            "notamsOnly": "false",
            "radius": "10"
        ]

        let body = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        request.timeoutInterval = 30

        return request
    }

    private func parseResponse(_ data: Data) throws -> [NOTAM] {
        // Try to parse the response
        do {
            let response = try JSONDecoder().decode(NOTAMSearchResponse.self, from: data)

            if let error = response.error {
                throw NOTAMError.apiError(statusCode: nil, message: error)
            }

            guard let items = response.notamList else {
                return []
            }

            return items.compactMap { $0.toNOTAM() }
        } catch let error as NOTAMError {
            throw error
        } catch {
            // Try alternate parsing if the structure is different
            if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                return parseAlternateFormat(json)
            }
            throw NOTAMError.parsingFailed(error)
        }
    }

    private func parseAlternateFormat(_ json: [[String: Any]]) -> [NOTAM] {
        // Handle alternate JSON structures from the API
        return json.compactMap { dict -> NOTAM? in
            guard let id = dict["id"] as? String ?? dict["notamId"] as? String,
                  let text = dict["icaoMessage"] as? String ?? dict["traditionalMessage"] as? String ?? dict["text"] as? String else {
                return nil
            }

            let series = dict["series"] as? String ?? ""
            let number = dict["number"] as? String ?? id
            let location = dict["location"] as? String ?? dict["affectedFIR"] as? String ?? ""

            return NOTAM(
                id: id,
                series: series,
                number: number,
                type: .new,
                issued: Date(),
                affectedFIR: location,
                selectionCode: nil,
                traffic: nil,
                purpose: nil,
                scope: nil,
                minimumFL: nil,
                maximumFL: nil,
                location: location,
                effectiveStart: Date(),
                effectiveEnd: nil,
                isEstimatedEnd: false,
                isPermanent: false,
                text: text,
                coordinates: nil
            )
        }
    }
}

// MARK: - Errors

enum NOTAMError: LocalizedError {
    case invalidURL
    case invalidResponse
    case rateLimited
    case serverError
    case networkUnavailable
    case parsingFailed(Error)
    case apiError(statusCode: Int?, message: String?)
    case allFetchesFailed([String: Error])
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimited:
            return "Too many requests. Please wait and try again."
        case .serverError:
            return "Server error. Please try again later."
        case .networkUnavailable:
            return "Network unavailable. Please check your connection."
        case .parsingFailed:
            return "Failed to parse NOTAM data"
        case .apiError(_, let message):
            return message ?? "API error occurred"
        case .allFetchesFailed:
            return "Failed to fetch NOTAMs for all locations"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
