import Foundation

/// Translates NOTAM abbreviations to plain English
final class NOTAMTranslator {
    static let shared = NOTAMTranslator()

    // MARK: - Main Translation

    func translate(_ notam: NOTAM) -> TranslatedNOTAM {
        let sections = parseSections(notam)
        let plainText = translateText(notam.text)

        return TranslatedNOTAM(
            original: notam,
            summary: generateSummary(notam, sections: sections),
            plainText: plainText,
            sections: sections
        )
    }

    // MARK: - Section Parsing

    private func parseSections(_ notam: NOTAM) -> [NOTAMSection] {
        var sections: [NOTAMSection] = []

        // Type section
        sections.append(NOTAMSection(
            title: "Type",
            icon: "doc.text",
            content: notam.type.displayName
        ))

        // Location section
        sections.append(NOTAMSection(
            title: "Location",
            icon: "mappin.circle",
            content: formatLocation(notam)
        ))

        // Effective period
        sections.append(NOTAMSection(
            title: "Effective Period",
            icon: "calendar",
            content: notam.effectivePeriodDescription
        ))

        // Altitude restrictions
        if let minFL = notam.minimumFL, let maxFL = notam.maximumFL {
            sections.append(NOTAMSection(
                title: "Altitude",
                icon: "arrow.up.arrow.down",
                content: formatAltitude(min: minFL, max: maxFL)
            ))
        }

        // Scope
        if let scope = notam.scope {
            sections.append(NOTAMSection(
                title: "Scope",
                icon: "scope",
                content: translateScope(scope)
            ))
        }

        // Coordinates
        if let coords = notam.coordinates {
            sections.append(NOTAMSection(
                title: "Coordinates",
                icon: "location",
                content: formatCoordinates(coords)
            ))
        }

        return sections
    }

    // MARK: - Text Translation

    private func translateText(_ text: String) -> String {
        var result = text

        // Replace common abbreviations
        for (abbr, full) in abbreviations {
            let pattern = "\\b\(abbr)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                result = regex.stringByReplacingMatches(
                    in: result,
                    range: NSRange(result.startIndex..., in: result),
                    withTemplate: full
                )
            }
        }

        // Clean up formatting
        result = result
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return result
    }

    // MARK: - Formatters

    private func formatLocation(_ notam: NOTAM) -> String {
        var parts: [String] = []
        parts.append(notam.location)
        if notam.affectedFIR != notam.location {
            parts.append("FIR: \(notam.affectedFIR)")
        }
        return parts.joined(separator: "\n")
    }

    private func formatAltitude(min: String, max: String) -> String {
        let minAlt = formatFlightLevel(min)
        let maxAlt = formatFlightLevel(max)

        if min == "000" && max == "999" {
            return "All altitudes (surface to unlimited)"
        }

        return "From \(minAlt) to \(maxAlt)"
    }

    private func formatFlightLevel(_ fl: String) -> String {
        guard let value = Int(fl) else { return fl }

        if value == 0 {
            return "surface"
        } else if value == 999 {
            return "unlimited"
        } else if value < 100 {
            return "\(value * 100) feet"
        } else {
            return "FL\(fl)"
        }
    }

    private func formatCoordinates(_ coords: Coordinates) -> String {
        let lat = formatDegrees(coords.latitude, isLatitude: true)
        let lon = formatDegrees(coords.longitude, isLatitude: false)

        var result = "\(lat), \(lon)"

        if let radius = coords.radius {
            result += "\nRadius: \(Int(radius)) NM"
        }

        return result
    }

    private func formatDegrees(_ value: Double, isLatitude: Bool) -> String {
        let direction = isLatitude ? (value >= 0 ? "N" : "S") : (value >= 0 ? "E" : "W")
        let absValue = abs(value)
        let degrees = Int(absValue)
        let minutes = (absValue - Double(degrees)) * 60

        return String(format: "%d°%.1f'%@", degrees, minutes, direction)
    }

    private func translateScope(_ scope: String) -> String {
        let scopes: [Character: String] = [
            "A": "Aerodrome",
            "E": "En-route",
            "W": "Navigation warning",
            "K": "Checklist"
        ]

        return scope.map { scopes[$0] ?? String($0) }.joined(separator: ", ")
    }

    private func generateSummary(_ notam: NOTAM, sections: [NOTAMSection]) -> String {
        // Try to extract the main purpose from the NOTAM text
        let text = notam.text.uppercased()

        if text.contains("RWY") && text.contains("CLSD") {
            return "Runway closure at \(notam.location)"
        }
        if text.contains("TWY") && text.contains("CLSD") {
            return "Taxiway closure at \(notam.location)"
        }
        if text.contains("AD CLSD") || text.contains("AERODROME CLSD") {
            return "Airport closed: \(notam.location)"
        }
        if text.contains("NAV") || text.contains("VOR") || text.contains("NDB") || text.contains("ILS") {
            return "Navigation aid outage at \(notam.location)"
        }
        if text.contains("OBST") || text.contains("CRANE") || text.contains("TOWER") {
            return "Obstruction warning near \(notam.location)"
        }
        if text.contains("TFR") || text.contains("RESTRICTED") || text.contains("PROHIBITED") {
            return "Airspace restriction affecting \(notam.location)"
        }
        if text.contains("BIRD") {
            return "Bird activity warning at \(notam.location)"
        }
        if text.contains("WIP") || text.contains("WORK IN PROGRESS") {
            return "Construction/work in progress at \(notam.location)"
        }

        return "NOTAM for \(notam.location)"
    }

    // MARK: - Abbreviation Dictionary

    private let abbreviations: [String: String] = [
        // Common operational
        "ABN": "Aerodrome beacon",
        "ABV": "Above",
        "ACFT": "Aircraft",
        "ACT": "Active",
        "AD": "Aerodrome",
        "ADJ": "Adjacent",
        "AGL": "Above ground level",
        "AIP": "Aeronautical Information Publication",
        "AIRMET": "Airmen's Meteorological Information",
        "ALS": "Approach lighting system",
        "ALT": "Altitude",
        "AMDT": "Amendment",
        "AMSL": "Above mean sea level",
        "AP": "Airport",
        "APCH": "Approach",
        "APR": "April",
        "APRX": "Approximately",
        "APT": "Airport",
        "ARPT": "Airport",
        "ARR": "Arrival",
        "ASDA": "Accelerate-stop distance available",
        "ASOS": "Automated Surface Observing System",
        "ATC": "Air Traffic Control",
        "ATIS": "Automatic Terminal Information Service",
        "AUTH": "Authority/Authorized",
        "AVBL": "Available",
        "AWY": "Airway",

        // B
        "BCN": "Beacon",
        "BLW": "Below",
        "BTN": "Between",

        // C
        "CAT": "Category",
        "CLSD": "Closed",
        "CLSD": "Closed",
        "CTC": "Contact",
        "CTL": "Control",
        "CTR": "Control zone",

        // D
        "DA": "Decision altitude",
        "DEP": "Departure",
        "DH": "Decision height",
        "DIST": "Distance",
        "DME": "Distance measuring equipment",
        "DVOR": "Doppler VOR",

        // E
        "EFAS": "En Route Flight Advisory Service",
        "EFF": "Effective",
        "ELEV": "Elevation",
        "EMERG": "Emergency",
        "EXC": "Except",

        // F
        "FAA": "Federal Aviation Administration",
        "FDC": "Flight Data Center",
        "FIR": "Flight Information Region",
        "FL": "Flight level",
        "FLT": "Flight",
        "FM": "From",
        "FNA": "Final approach",
        "FREQ": "Frequency",
        "FRI": "Friday",
        "FSS": "Flight Service Station",
        "FT": "Feet",

        // G
        "GND": "Ground",
        "GP": "Glide path",
        "GPS": "Global Positioning System",

        // H
        "HELI": "Helicopter",
        "HGT": "Height",
        "HIRL": "High intensity runway lights",
        "HOL": "Holiday",
        "HR": "Hour",
        "HRS": "Hours",

        // I
        "IAF": "Initial approach fix",
        "IAP": "Instrument approach procedure",
        "ICAO": "International Civil Aviation Organization",
        "IDENT": "Identification",
        "IFR": "Instrument flight rules",
        "ILS": "Instrument landing system",
        "IMC": "Instrument meteorological conditions",
        "IN": "Inches",
        "INOP": "Inoperative",
        "INTL": "International",

        // K
        "KT": "Knots",

        // L
        "LAT": "Latitude",
        "LDA": "Landing distance available",
        "LGT": "Light/Lighting",
        "LGTD": "Lighted",
        "LIRL": "Low intensity runway lights",
        "LLZ": "Localizer",
        "LM": "Locator middle marker",
        "LOC": "Localizer",
        "LONG": "Longitude",
        "LO": "Locator outer marker",

        // M
        "MAINT": "Maintenance",
        "MALS": "Medium intensity approach lighting system",
        "MALSR": "Medium intensity approach lighting system with runway alignment indicator",
        "MAX": "Maximum",
        "MDA": "Minimum descent altitude",
        "MET": "Meteorological",
        "MIN": "Minimum/Minutes",
        "MIRL": "Medium intensity runway lights",
        "MKR": "Marker beacon",
        "MLS": "Microwave landing system",
        "MM": "Middle marker",
        "MNM": "Minimum",
        "MNT": "Monitor",
        "MON": "Monday",
        "MSL": "Mean sea level",

        // N
        "NA": "Not available",
        "NAV": "Navigation",
        "NAVAID": "Navigation aid",
        "NDB": "Non-directional radio beacon",
        "NGT": "Night",
        "NM": "Nautical miles",
        "NML": "Normal",
        "NOTAM": "Notice to Air Missions",
        "NR": "Number",

        // O
        "OBS": "Obstacle/Observe",
        "OBST": "Obstruction",
        "OM": "Outer marker",
        "OPR": "Operate/Operator",
        "OPS": "Operations",
        "OTS": "Out of service",

        // P
        "PAPI": "Precision approach path indicator",
        "PAR": "Precision approach radar",
        "PARL": "Parallel",
        "PCL": "Pilot controlled lighting",
        "PCT": "Percent",
        "PERM": "Permanent",
        "PJE": "Parachute jumping exercise",
        "PN": "Prior notice required",
        "PPR": "Prior permission required",
        "PROC": "Procedure",
        "PROP": "Propeller",
        "PSR": "Primary surveillance radar",
        "PVT": "Private",

        // R
        "RAIL": "Runway alignment indicator lights",
        "RCL": "Runway centerline",
        "RCLL": "Runway centerline lights",
        "RCO": "Remote communication outlet",
        "RDR": "Radar",
        "REIL": "Runway end identifier lights",
        "RLLS": "Runway lead-in light system",
        "RNAV": "Area navigation",
        "RNP": "Required navigation performance",
        "RSR": "En route surveillance radar",
        "RSVN": "Reservation",
        "RTR": "Remote transmitter/receiver",
        "RVR": "Runway visual range",
        "RWY": "Runway",

        // S
        "SAT": "Saturday",
        "SDF": "Simplified directional facility",
        "SFC": "Surface",
        "SID": "Standard instrument departure",
        "SIGMET": "Significant Meteorological Information",
        "SIMUL": "Simultaneous",
        "SN": "Snow",
        "SSALF": "Simplified short approach lighting system with sequenced flashers",
        "SSALR": "Simplified short approach lighting system with runway alignment indicator lights",
        "SSALS": "Simplified short approach lighting system",
        "SSR": "Secondary surveillance radar",
        "STAR": "Standard terminal arrival route",
        "SUN": "Sunday",
        "SVN": "Service",

        // T
        "TACAN": "Tactical air navigation aid",
        "TAR": "Terminal area surveillance radar",
        "TDZ": "Touchdown zone",
        "TDZE": "Touchdown zone elevation",
        "TFC": "Traffic",
        "TFR": "Temporary flight restriction",
        "TGL": "Touch-and-go landing",
        "THR": "Threshold",
        "THRU": "Through",
        "THU": "Thursday",
        "TIL": "Until",
        "TML": "Terminal",
        "TODA": "Take-off distance available",
        "TORA": "Take-off run available",
        "TUE": "Tuesday",
        "TWR": "Tower",
        "TWY": "Taxiway",

        // U
        "U/S": "Unserviceable",
        "UNL": "Unlimited",
        "UNLGTD": "Unlighted",
        "USBL": "Usable",

        // V
        "VASI": "Visual approach slope indicator",
        "VFR": "Visual flight rules",
        "VIA": "By way of",
        "VMC": "Visual meteorological conditions",
        "VOR": "VHF omnidirectional range",
        "VORTAC": "VOR and TACAN combination",

        // W
        "WDI": "Wind direction indicator",
        "WED": "Wednesday",
        "WEF": "With effect from",
        "WI": "Within",
        "WID": "Width",
        "WIP": "Work in progress",
        "WKDAYS": "Weekdays",
        "WKEND": "Weekend",
        "WPT": "Waypoint",

        // X
        "XPDR": "Transponder"
    ]
}

// MARK: - Models

struct TranslatedNOTAM {
    let original: NOTAM
    let summary: String
    let plainText: String
    let sections: [NOTAMSection]
}

struct NOTAMSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let content: String
}
