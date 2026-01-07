import Foundation

/// Represents a Flight Information Region (FIR)
struct ATSUnit: Codable, Identifiable, Hashable {
    let icao: String
    let name: String
    let country: String

    var id: String { icao }

    /// Converts to app's FIR model for use in settings
    func toFIR() -> FIR {
        FIR(icaoCode: icao, displayName: name)
    }
}

/// Container for ATS units JSON file
struct ATSUnitsData: Codable {
    let schemaVersion: String
    let generatedAt: String
    let units: [ATSUnit]
}
