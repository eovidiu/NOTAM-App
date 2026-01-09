import Foundation
import SwiftUI

/// Severity level for NOTAMs based on operational impact
enum NOTAMSeverity: String, Codable, CaseIterable {
    case critical   // FIR/airspace prohibited, no ATS
    case warning    // Airport/runway closed, restricted areas active
    case caution    // TFR, partial closures
    case info       // Normal NOTAMs

    /// Numeric priority for comparison (lower = more severe)
    var priority: Int {
        switch self {
        case .critical: return 0
        case .warning: return 1
        case .caution: return 2
        case .info: return 3
        }
    }

    /// Returns true if this severity meets or exceeds the given threshold
    func meetsThreshold(_ threshold: NOTAMSeverity) -> Bool {
        self.priority <= threshold.priority
    }

    var color: Color {
        switch self {
        case .critical: return .red
        case .warning: return .orange
        case .caution: return .yellow
        case .info: return .green
        }
    }

    var icon: String {
        switch self {
        case .critical: return "exclamationmark.octagon.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .caution: return "exclamationmark.circle.fill"
        case .info: return "checkmark.circle.fill"
        }
    }

    var label: String {
        switch self {
        case .critical: return "Critical"
        case .warning: return "Warning"
        case .caution: return "Caution"
        case .info: return "Active"
        }
    }
}

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

    /// Determines severity based on NOTAM content
    var severity: NOTAMSeverity {
        let upperText = text.uppercased()

        // CRITICAL: FIR/airspace prohibited, no ATS
        if upperText.contains("ATS IS NOT PROVIDED") ||
           upperText.contains("ATS NOT AVAILABLE") ||
           upperText.contains("NO ATC SERVICE") {
            return .critical
        }

        if upperText.contains("PROHIBITED") &&
           (upperText.contains("FIR") || upperText.contains("UIR") || upperText.contains("AIRSPACE")) {
            return .critical
        }

        if upperText.contains("CLSD") && upperText.contains("ALL FLIGHTS") {
            return .critical
        }

        // WARNING: Airport/runway closed, restricted areas active
        if upperText.contains("AD CLSD") || upperText.contains("AERODROME CLSD") ||
           upperText.contains("AIRPORT CLSD") || upperText.contains("AIRPORT CLOSED") {
            return .warning
        }

        if upperText.contains("RWY") && upperText.contains("CLSD") {
            return .warning
        }

        if (upperText.contains("RESTRICTED AREA") || upperText.contains("PROHIBITED AREA")) &&
           (upperText.contains("ACT") || upperText.contains("ACTIVE")) {
            return .warning
        }

        // CAUTION: TFR, partial closures, general restrictions
        if upperText.contains("TFR") || upperText.contains("TEMPORARY FLIGHT RESTRICTION") {
            return .caution
        }

        if upperText.contains("CLSD") || upperText.contains("CLOSED") {
            return .caution
        }

        if upperText.contains("RESTRICTED") || upperText.contains("PROHIBITED") {
            return .caution
        }

        // INFO: Default for normal NOTAMs
        return .info
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
    // FAA API actual field names
    let facilityDesignator: String?
    let notamNumber: String?
    let featureName: String?
    let issueDate: String?
    let startDate: String?
    let endDate: String?
    let source: String?
    let sourceType: String?
    let icaoMessage: String?
    let traditionalMessage: String?
    let plainLanguageMessage: String?
    let icaoId: String?
    let airportName: String?
    let status: String?
    let keyword: String?
    let mapPointer: String?
    let transactionID: Int?

    func toNOTAM() -> NOTAM? {
        // Use notamNumber as the unique ID
        guard let notamNum = notamNumber else {
            return nil
        }

        // Get text from traditionalMessage or icaoMessage (prefer traditional as icao is often just a space)
        let text = (traditionalMessage?.trimmingCharacters(in: .whitespaces).isEmpty == false ? traditionalMessage : nil)
            ?? (icaoMessage?.trimmingCharacters(in: .whitespaces).isEmpty == false ? icaoMessage : nil)
            ?? plainLanguageMessage
            ?? "No message available"

        // Parse notam number for series (e.g., "LTA-N90-114" -> series="LTA", number="N90-114")
        let parts = notamNum.split(separator: "-", maxSplits: 1)
        let series = parts.count > 0 ? String(parts[0]) : "N"
        let number = parts.count > 1 ? String(parts[1]) : notamNum

        // Date formatter for FAA format: "MM/dd/yyyy HHmm"
        let faaDateFormatter = DateFormatter()
        faaDateFormatter.dateFormat = "MM/dd/yyyy HHmm"
        faaDateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        func parseDate(_ string: String?) -> Date? {
            guard let string = string, !string.isEmpty else { return nil }
            return faaDateFormatter.date(from: string)
        }

        let issuedDate = parseDate(issueDate) ?? Date()
        let startDateValue = parseDate(startDate) ?? Date()

        var endDateValue: Date? = nil
        var isEstimated = false
        var isPerm = false

        if let endStr = endDate?.uppercased() {
            if endStr.contains("PERM") {
                isPerm = true
            } else if endStr.contains("EST") {
                isEstimated = true
                let cleanedEnd = endStr.replacingOccurrences(of: "EST", with: "").trimmingCharacters(in: .whitespaces)
                endDateValue = parseDate(cleanedEnd)
            } else {
                endDateValue = parseDate(endDate)
            }
        }

        // Parse coordinates from mapPointer (e.g., "POINT(-73.7789 40.6398)")
        var coords: Coordinates? = nil
        if let pointer = mapPointer, pointer.hasPrefix("POINT(") {
            let coordStr = pointer.dropFirst(6).dropLast()
            let coordParts = coordStr.split(separator: " ")
            if coordParts.count == 2,
               let lon = Double(coordParts[0]),
               let lat = Double(coordParts[1]) {
                coords = Coordinates(latitude: lat, longitude: lon, radius: nil)
            }
        }

        let location = icaoId ?? facilityDesignator ?? ""

        return NOTAM(
            id: notamNum,
            series: series,
            number: number,
            type: .new,
            issued: issuedDate,
            affectedFIR: location,
            selectionCode: nil,
            traffic: nil,
            purpose: nil,
            scope: nil,
            minimumFL: nil,
            maximumFL: nil,
            location: location,
            effectiveStart: startDateValue,
            effectiveEnd: endDateValue,
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
