import Foundation

/// Represents an Air Traffic Services unit (FIR, ACC, UIR, etc.)
struct ATSUnit: Codable, Identifiable, Hashable {
    let id: String
    let icao: String
    let type: UnitType
    let name: String
    let controllingState: ControllingState
    let tags: [String]
    let notes: String?

    enum UnitType: String, Codable {
        case FIR
        case ACC
        case UIR
        case ARTCC
    }

    struct ControllingState: Codable, Hashable {
        let name: String
        let iso2: String
        let iso3: String
    }

    /// Converts to app's FIR model for use in settings
    func toFIR() -> FIR {
        FIR(icaoCode: icao, displayName: name)
    }
}

/// Container for ATS units JSON file
struct ATSUnitsData: Codable {
    let schemaVersion: String
    let generatedAt: String
    let sources: [Source]
    let units: [ATSUnit]

    struct Source: Codable {
        let name: String
        let url: String
    }
}
