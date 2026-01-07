import Foundation

/// Represents a single NOTAM (Notice to Air Missions)
struct NOTAM: Codable, Identifiable, Hashable {
    let id: String
    let series: String
    let number: String
    let type: NOTAMType
    let issued: Date
    let affectedFIR: String
    let selectionCode: String?
    let traffic: String?
    let purpose: String?
    let scope: String?
    let minimumFL: String?
    let maximumFL: String?
    let location: String
    let effectiveStart: Date
    let effectiveEnd: Date?
    let isEstimatedEnd: Bool
    let isPermanent: Bool
    let text: String
    let coordinates: Coordinates?

    var displayId: String {
        "\(series)\(number)"
    }

    var isActive: Bool {
        let now = Date()
        guard effectiveStart <= now else { return false }
        if isPermanent { return true }
        guard let end = effectiveEnd else { return true }
        return end > now
    }

    var effectivePeriodDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        let start = formatter.string(from: effectiveStart)

        if isPermanent {
            return "\(start) - PERMANENT"
        }

        if let end = effectiveEnd {
            let endStr = formatter.string(from: end)
            let suffix = isEstimatedEnd ? " (EST)" : ""
            return "\(start) - \(endStr)\(suffix)"
        }

        return "\(start) - Unknown"
    }
}

enum NOTAMType: String, Codable, CaseIterable {
    case new = "N"
    case replacement = "R"
    case cancellation = "C"

    var displayName: String {
        switch self {
        case .new: return "New"
        case .replacement: return "Replacement"
        case .cancellation: return "Cancellation"
        }
    }
}

struct Coordinates: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let radius: Double? // in nautical miles
}

// MARK: - API Response Models

struct NOTAMSearchResponse: Codable {
    let notamList: [NOTAMResponseItem]?
    let error: String?
}

struct NOTAMResponseItem: Codable {
    let id: String?
    let series: String?
    let number: String?
    let type: String?
    let issued: String?
    let affectedFIR: String?
    let selectionCode: String?
    let traffic: String?
    let purpose: String?
    let scope: String?
    let minimumFL: String?
    let maximumFL: String?
    let location: String?
    let effectiveStart: String?
    let effectiveEnd: String?
    let icaoMessage: String?
    let traditionalMessage: String?
    let coordinates: String?

    func toNOTAM() -> NOTAM? {
        guard let id = id,
              let series = series,
              let number = number,
              let location = location,
              let text = icaoMessage ?? traditionalMessage else {
            return nil
        }

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let altFormatter = ISO8601DateFormatter()
        altFormatter.formatOptions = [.withInternetDateTime]

        func parseDate(_ string: String?) -> Date? {
            guard let string = string else { return nil }
            return dateFormatter.date(from: string) ?? altFormatter.date(from: string)
        }

        let issuedDate = parseDate(issued) ?? Date()
        let startDate = parseDate(effectiveStart) ?? Date()

        var endDate: Date? = nil
        var isEstimated = false
        var isPerm = false

        if let endStr = effectiveEnd?.uppercased() {
            if endStr.contains("PERM") {
                isPerm = true
            } else if endStr.contains("EST") {
                isEstimated = true
                let cleanedEnd = endStr.replacingOccurrences(of: "EST", with: "").trimmingCharacters(in: .whitespaces)
                endDate = parseDate(cleanedEnd)
            } else {
                endDate = parseDate(effectiveEnd)
            }
        }

        var coords: Coordinates? = nil
        if let coordStr = coordinates {
            coords = parseCoordinates(coordStr)
        }

        return NOTAM(
            id: id,
            series: series,
            number: number,
            type: NOTAMType(rawValue: type ?? "N") ?? .new,
            issued: issuedDate,
            affectedFIR: affectedFIR ?? location,
            selectionCode: selectionCode,
            traffic: traffic,
            purpose: purpose,
            scope: scope,
            minimumFL: minimumFL,
            maximumFL: maximumFL,
            location: location,
            effectiveStart: startDate,
            effectiveEnd: endDate,
            isEstimatedEnd: isEstimated,
            isPermanent: isPerm,
            text: text,
            coordinates: coords
        )
    }

    private func parseCoordinates(_ string: String) -> Coordinates? {
        // Format: "4426N02615E" or "4426N02615E005" (with radius)
        let pattern = #"(\d{2})(\d{2})([NS])(\d{3})(\d{2})([EW])(\d{3})?"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)) else {
            return nil
        }

        func group(_ n: Int) -> String? {
            guard let range = Range(match.range(at: n), in: string) else { return nil }
            return String(string[range])
        }

        guard let latDeg = Double(group(1) ?? ""),
              let latMin = Double(group(2) ?? ""),
              let latDir = group(3),
              let lonDeg = Double(group(4) ?? ""),
              let lonMin = Double(group(5) ?? ""),
              let lonDir = group(6) else {
            return nil
        }

        var lat = latDeg + latMin / 60.0
        if latDir == "S" { lat = -lat }

        var lon = lonDeg + lonMin / 60.0
        if lonDir == "W" { lon = -lon }

        let radius = Double(group(7) ?? "")

        return Coordinates(latitude: lat, longitude: lon, radius: radius)
    }
}
