import SwiftUI

/// Aviation Glass Typography System
/// SF Pro Display for headlines, SF Pro Text for body, SF Mono for data
enum AviationFont {

    // MARK: - Display Fonts (SF Pro Display)

    /// Hero Title - 34pt Bold
    /// Usage: Main screen titles like "NOTAMs"
    static func heroTitle() -> Font {
        .system(size: 34, weight: .bold, design: .default)
    }

    /// Section Header - 22pt Semibold
    /// Usage: FIR group headers, modal titles
    static func sectionHeader() -> Font {
        .system(size: 22, weight: .semibold, design: .default)
    }

    // MARK: - Text Fonts (SF Pro Text)

    /// Card Title - 17pt Semibold
    /// Usage: NOTAM titles, list item headers
    static func cardTitle() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    /// Body Primary - 16pt Regular
    /// Usage: Main content, descriptions
    static func bodyPrimary() -> Font {
        .system(size: 16, weight: .regular, design: .default)
    }

    /// Body Secondary - 14pt Regular
    /// Usage: Supporting text, metadata
    static func bodySecondary() -> Font {
        .system(size: 14, weight: .regular, design: .default)
    }

    /// Label - 12pt Medium
    /// Usage: Section labels (ALL CAPS with tracking)
    static func label() -> Font {
        .system(size: 12, weight: .medium, design: .default)
    }

    /// Caption - 11pt Regular
    /// Usage: Timestamps, small annotations
    static func caption() -> Font {
        .system(size: 11, weight: .regular, design: .default)
    }

    // MARK: - Monospace Fonts (SF Mono)

    /// NOTAM ID Badge - 13pt Bold Mono
    /// Usage: NOTAM identifiers like "A0234/24"
    static func notamId() -> Font {
        .system(size: 13, weight: .bold, design: .monospaced)
    }

    /// Timestamp - 12pt Medium Mono
    /// Usage: Dates, times, UTC timestamps
    static func timestamp() -> Font {
        .system(size: 12, weight: .medium, design: .monospaced)
    }

    /// Raw NOTAM Text - 14pt Regular Mono
    /// Usage: Original NOTAM text display
    static func rawText() -> Font {
        .system(size: 14, weight: .regular, design: .monospaced)
    }

    // MARK: - Special Fonts

    /// Severity Badge - 10pt Heavy Rounded
    /// Usage: CRITICAL, WARNING labels
    static func severityBadge() -> Font {
        .system(size: 10, weight: .heavy, design: .rounded)
    }

    /// Large Counter - 48pt Bold Rounded
    /// Usage: Animated NOTAM counts
    static func counter() -> Font {
        .system(size: 48, weight: .bold, design: .rounded)
    }

    /// FIR Code - 18pt Bold Mono
    /// Usage: FIR identifiers like "KJFK"
    static func firCode() -> Font {
        .system(size: 18, weight: .bold, design: .monospaced)
    }

    /// FIR Code Small - 14pt Bold Mono
    /// Usage: Smaller FIR identifiers in lists
    static func firCodeSmall() -> Font {
        .system(size: 14, weight: .bold, design: .monospaced)
    }
}

// MARK: - Text Style Modifiers

extension View {
    /// Apply hero title styling
    func heroTitleStyle() -> some View {
        self
            .font(AviationFont.heroTitle())
            .tracking(-0.4)
    }

    /// Apply section header styling
    func sectionHeaderStyle() -> some View {
        self
            .font(AviationFont.sectionHeader())
            .tracking(-0.26)
    }

    /// Apply card title styling
    func cardTitleStyle() -> some View {
        self
            .font(AviationFont.cardTitle())
            .tracking(-0.4)
    }

    /// Apply label styling (ALL CAPS with tracking)
    func labelStyle() -> some View {
        self
            .font(AviationFont.label())
            .tracking(0.5)
            .textCase(.uppercase)
    }

    /// Apply NOTAM ID styling
    func notamIdStyle() -> some View {
        self
            .font(AviationFont.notamId())
            .tracking(0.5)
    }

    /// Apply timestamp styling
    func timestampStyle() -> some View {
        self
            .font(AviationFont.timestamp())
            .tracking(0.3)
    }

    /// Apply severity badge styling
    func severityBadgeStyle() -> some View {
        self
            .font(AviationFont.severityBadge())
            .tracking(1.2)
            .textCase(.uppercase)
    }

    /// Apply FIR code styling
    func firCodeStyle() -> some View {
        self
            .font(AviationFont.firCode())
            .tracking(2)
    }
}

// MARK: - Preview

#Preview("Typography Scale") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            Group {
                Text("Display Fonts")
                    .font(.caption)
                    .foregroundStyle(Color("ElectricCyan"))

                Text("NOTAMs")
                    .heroTitleStyle()
                    .foregroundStyle(Color("TextPrimary"))

                Text("KJFK - New York")
                    .sectionHeaderStyle()
                    .foregroundStyle(Color("TextPrimary"))

                Text("Runway 04L/22R Closed")
                    .cardTitleStyle()
                    .foregroundStyle(Color("TextPrimary"))
            }

            Divider()

            Group {
                Text("Body Fonts")
                    .font(.caption)
                    .foregroundStyle(Color("ElectricCyan"))

                Text("The runway is closed for scheduled maintenance until further notice.")
                    .font(AviationFont.bodyPrimary())
                    .foregroundStyle(Color("TextSecondary"))

                Text("Last updated 5 minutes ago")
                    .font(AviationFont.bodySecondary())
                    .foregroundStyle(Color("TextTertiary"))
            }

            Divider()

            Group {
                Text("Technical Fonts")
                    .font(.caption)
                    .foregroundStyle(Color("ElectricCyan"))

                Text("A0234/24")
                    .notamIdStyle()
                    .foregroundStyle(Color("TextPrimary"))

                Text("2024-01-15 14:32 UTC")
                    .timestampStyle()
                    .foregroundStyle(Color("TextTertiary"))

                Text("EFFECTIVE")
                    .labelStyle()
                    .foregroundStyle(Color("TextTertiary"))

                Text("CRITICAL")
                    .severityBadgeStyle()
                    .foregroundStyle(Color("CrimsonPulse"))
            }

            Divider()

            Group {
                Text("FIR Code")
                    .font(.caption)
                    .foregroundStyle(Color("ElectricCyan"))

                Text("KJFK")
                    .firCodeStyle()
                    .foregroundStyle(Color("TextPrimary"))
            }
        }
        .padding()
    }
    .background(Color("DeepSpace"))
}
