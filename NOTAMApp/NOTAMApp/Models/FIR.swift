import Foundation

/// Represents a Flight Information Region configuration
struct FIR: Codable, Identifiable, Hashable {
    let id: UUID
    var icaoCode: String
    var displayName: String
    var isEnabled: Bool

    init(id: UUID = UUID(), icaoCode: String, displayName: String? = nil, isEnabled: Bool = true) {
        self.id = id
        self.icaoCode = icaoCode.uppercased()
        self.displayName = displayName ?? icaoCode.uppercased()
        self.isEnabled = isEnabled
    }

    /// Validates that the ICAO code is properly formatted (4 uppercase letters)
    var isValidICAO: Bool {
        FIR.isValidICAOCode(icaoCode)
    }

    static func isValidICAOCode(_ code: String) -> Bool {
        let pattern = "^[A-Z]{4}$"
        return code.uppercased().range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - Common FIRs

extension FIR {
    /// Default FIR for the app (Bucharest, Romania)
    static let defaultFIR = FIR(
        icaoCode: "LROP",
        displayName: "Bucharest Henri Coandă"
    )

    /// Common FIRs for quick selection
    static let commonFIRs: [FIR] = [
        FIR(icaoCode: "LROP", displayName: "Bucharest Henri Coandă"),
        FIR(icaoCode: "LRBS", displayName: "Bucharest Băneasa"),
        FIR(icaoCode: "LRCL", displayName: "Cluj-Napoca"),
        FIR(icaoCode: "LRTM", displayName: "Timișoara"),
        FIR(icaoCode: "LRIA", displayName: "Iași"),
        FIR(icaoCode: "KJFK", displayName: "New York JFK"),
        FIR(icaoCode: "KLAX", displayName: "Los Angeles"),
        FIR(icaoCode: "EGLL", displayName: "London Heathrow"),
        FIR(icaoCode: "LFPG", displayName: "Paris CDG"),
        FIR(icaoCode: "EDDF", displayName: "Frankfurt"),
    ]
}
