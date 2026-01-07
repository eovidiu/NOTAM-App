import Foundation

/// Service for loading and searching ATS units
final class ATSUnitService {
    static let shared = ATSUnitService()

    private var units: [ATSUnit] = []
    private var isLoaded = false

    private init() {
        loadUnits()
    }

    // MARK: - Loading

    private func loadUnits() {
        guard let url = Bundle.main.url(forResource: "ats_units", withExtension: "json") else {
            print("ATSUnitService: ats_units.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let atsData = try decoder.decode(ATSUnitsData.self, from: data)
            units = atsData.units
            isLoaded = true
            print("ATSUnitService: Loaded \(units.count) ATS units")
        } catch {
            print("ATSUnitService: Failed to load ATS units: \(error.localizedDescription)")
        }
    }

    // MARK: - Search

    /// Searches ATS units by ICAO code, name, or country
    /// - Parameter query: Search query string
    /// - Returns: Matching ATS units, sorted by relevance
    func search(_ query: String) -> [ATSUnit] {
        guard !query.isEmpty else { return [] }

        let query = query.uppercased()

        // Score and sort results by relevance
        let scored = units.compactMap { unit -> (ATSUnit, Int)? in
            let score = calculateScore(unit: unit, query: query)
            return score > 0 ? (unit, score) : nil
        }

        return scored
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }

    private func calculateScore(unit: ATSUnit, query: String) -> Int {
        var score = 0

        // Exact ICAO match - highest priority
        if unit.icao == query {
            score += 100
        }
        // ICAO starts with query
        else if unit.icao.hasPrefix(query) {
            score += 50
        }
        // ICAO contains query
        else if unit.icao.contains(query) {
            score += 30
        }

        // Name contains query (case insensitive)
        let nameUpper = unit.name.uppercased()
        if nameUpper.contains(query) {
            score += 20
        }

        // Country name contains query
        let countryUpper = unit.controllingState.name.uppercased()
        if countryUpper.contains(query) {
            score += 15
        }

        // ISO codes
        if unit.controllingState.iso2 == query || unit.controllingState.iso3 == query {
            score += 25
        }

        return score
    }

    /// Returns all units for a given country
    func unitsByCountry(_ countryCode: String) -> [ATSUnit] {
        let code = countryCode.uppercased()
        return units.filter {
            $0.controllingState.iso2 == code || $0.controllingState.iso3 == code
        }
    }

    /// Returns unit by exact ICAO code
    func unit(byICAO icao: String) -> ATSUnit? {
        units.first { $0.icao == icao.uppercased() }
    }

    /// Returns all loaded units
    var allUnits: [ATSUnit] {
        units
    }

    /// Returns unique countries from loaded units
    var countries: [ATSUnit.ControllingState] {
        Array(Set(units.map { $0.controllingState })).sorted { $0.name < $1.name }
    }
}
