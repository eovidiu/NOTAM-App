import Foundation

/// Service for loading and searching FIRs
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
            print("ATSUnitService: Loaded \(units.count) FIRs")
        } catch {
            print("ATSUnitService: Failed to load FIRs: \(error.localizedDescription)")
        }
    }

    // MARK: - Search

    /// Searches FIRs by ICAO code, name, or country
    /// - Parameter query: Search query string
    /// - Returns: Matching FIRs, sorted by relevance
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
        let countryUpper = unit.country.uppercased()
        if countryUpper.contains(query) {
            score += 15
        }

        return score
    }

    /// Returns all units for a given country
    func unitsByCountry(_ country: String) -> [ATSUnit] {
        let query = country.uppercased()
        return units.filter {
            $0.country.uppercased().contains(query)
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
    var countries: [String] {
        Array(Set(units.map { $0.country })).sorted()
    }
}
