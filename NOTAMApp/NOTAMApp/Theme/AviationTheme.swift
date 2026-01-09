import SwiftUI

/// Aviation Glass Design System Theme
/// Premium dark-first UI inspired by modern cockpit displays
@Observable
final class AviationTheme {
    static let shared = AviationTheme()

    private init() {}

    // MARK: - Background Colors

    /// Base background - Deep Space #0A0A0F
    var backgroundPrimary: Color { Color("DeepSpace") }

    /// Primary surface - Obsidian #12121A
    var backgroundSecondary: Color { Color("Obsidian") }

    /// Elevated cards - Graphite #1C1C28
    var backgroundElevated: Color { Color("Graphite") }

    /// Interactive elements - Slate Glass #252535
    var backgroundInteractive: Color { Color("SlateGlass") }

    // MARK: - Accent Colors

    /// Primary accent - Electric Cyan #00D4FF
    var accentPrimary: Color { Color("ElectricCyan") }

    /// Links, interactive - Neon Blue #4D9FFF
    var accentSecondary: Color { Color("NeonBlue") }

    /// Success, safe - Aurora Green #00FF94
    var accentSuccess: Color { Color("AuroraGreen") }

    /// Warning - Amber Alert #FFB800
    var accentWarning: Color { Color("AmberAlert") }

    /// Critical, danger - Crimson Pulse #FF3366
    var accentDanger: Color { Color("CrimsonPulse") }

    /// Special highlights - Violet Glow #9D4EDD
    var accentSpecial: Color { Color("VioletGlow") }

    /// Caution - Yellow #FFD600
    var accentCaution: Color { Color("CautionYellow") }

    // MARK: - Severity Colors

    var severityCritical: Color { Color("CrimsonPulse") }
    var severityWarning: Color { Color("AmberAlert") }
    var severityCaution: Color { Color("CautionYellow") }
    var severityInfo: Color { Color("AuroraGreen") }

    // MARK: - Text Colors

    /// Headlines, emphasis - Pure White
    var textPrimary: Color { Color("TextPrimary") }

    /// Primary text - Silver #E5E5EA
    var textSecondary: Color { Color("TextSecondary") }

    /// Secondary text - Platinum #A1A1AA
    var textTertiary: Color { Color("TextTertiary") }

    /// Disabled text - Graphite #6B6B7A
    var textDisabled: Color { Color("TextDisabled") }

    // MARK: - Glass Effect Colors

    var glassBorder: Color { Color("GlassBorder") }
    var glassBackground: Color { Color("GlassBackground") }

    // MARK: - Spacing

    /// 4pt base unit spacing system
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
    }

    // MARK: - Shadows

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat

        static let card = Shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        static let elevated = Shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 20)
        static let subtle = Shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Environment Key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = AviationTheme.shared
}

extension EnvironmentValues {
    var theme: AviationTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Color Extensions for Severity

extension AviationTheme {
    /// Get background color for severity level (15% opacity)
    func severityBackground(for severity: String) -> Color {
        switch severity.lowercased() {
        case "critical":
            return severityCritical.opacity(0.15)
        case "warning":
            return severityWarning.opacity(0.12)
        case "caution":
            return severityCaution.opacity(0.10)
        default:
            return severityInfo.opacity(0.10)
        }
    }

    /// Get border color for severity level (35-50% opacity)
    func severityBorder(for severity: String) -> Color {
        switch severity.lowercased() {
        case "critical":
            return severityCritical.opacity(0.50)
        case "warning":
            return severityWarning.opacity(0.35)
        case "caution":
            return severityCaution.opacity(0.30)
        default:
            return severityInfo.opacity(0.30)
        }
    }
}

// MARK: - Preview Helper

#Preview("Theme Colors") {
    let theme = AviationTheme.shared

    return ScrollView {
        VStack(spacing: 20) {
            // Backgrounds
            VStack(alignment: .leading, spacing: 8) {
                Text("Backgrounds")
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)

                HStack(spacing: 8) {
                    ColorSwatch(color: theme.backgroundPrimary, name: "Primary")
                    ColorSwatch(color: theme.backgroundSecondary, name: "Secondary")
                    ColorSwatch(color: theme.backgroundElevated, name: "Elevated")
                    ColorSwatch(color: theme.backgroundInteractive, name: "Interactive")
                }
            }

            // Accents
            VStack(alignment: .leading, spacing: 8) {
                Text("Accents")
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)

                HStack(spacing: 8) {
                    ColorSwatch(color: theme.accentPrimary, name: "Primary")
                    ColorSwatch(color: theme.accentSecondary, name: "Secondary")
                    ColorSwatch(color: theme.accentSuccess, name: "Success")
                    ColorSwatch(color: theme.accentWarning, name: "Warning")
                }
                HStack(spacing: 8) {
                    ColorSwatch(color: theme.accentDanger, name: "Danger")
                    ColorSwatch(color: theme.accentCaution, name: "Caution")
                    ColorSwatch(color: theme.accentSpecial, name: "Special")
                }
            }

            // Severity
            VStack(alignment: .leading, spacing: 8) {
                Text("Severity")
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)

                HStack(spacing: 8) {
                    ColorSwatch(color: theme.severityCritical, name: "Critical")
                    ColorSwatch(color: theme.severityWarning, name: "Warning")
                    ColorSwatch(color: theme.severityCaution, name: "Caution")
                    ColorSwatch(color: theme.severityInfo, name: "Info")
                }
            }
        }
        .padding()
    }
    .background(AviationTheme.shared.backgroundPrimary)
}

private struct ColorSwatch: View {
    let color: Color
    let name: String

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 40)
            Text(name)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
