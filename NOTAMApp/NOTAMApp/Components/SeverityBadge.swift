import SwiftUI

/// Severity Badge Display Variants
enum SeverityBadgeStyle {
    case compact   // Icon only
    case standard  // Icon + label
    case expanded  // Icon + label + description
}

/// Aviation Glass Severity Badge Component
/// Displays NOTAM severity with appropriate color coding and styling
struct SeverityBadge: View {
    let severity: NOTAMSeverity
    var style: SeverityBadgeStyle = .standard

    private var color: Color {
        switch severity {
        case .critical:
            return Color("CrimsonPulse")
        case .warning:
            return Color("AmberAlert")
        case .caution:
            return Color("CautionYellow")
        case .info:
            return Color("AuroraGreen")
        }
    }

    private var icon: String {
        switch severity {
        case .critical:
            return "exclamationmark.octagon.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .caution:
            return "exclamationmark.circle.fill"
        case .info:
            return "info.circle.fill"
        }
    }

    private var label: String {
        switch severity {
        case .critical:
            return "CRITICAL"
        case .warning:
            return "WARNING"
        case .caution:
            return "CAUTION"
        case .info:
            return "INFO"
        }
    }

    private var description: String {
        switch severity {
        case .critical:
            return "Airspace closure or major hazard"
        case .warning:
            return "Significant operational impact"
        case .caution:
            return "Operational awareness required"
        case .info:
            return "General information"
        }
    }

    var body: some View {
        switch style {
        case .compact:
            compactBadge
        case .standard:
            standardBadge
        case .expanded:
            expandedBadge
        }
    }

    // MARK: - Compact (Icon Only)

    private var compactBadge: some View {
        Image(systemName: icon)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(color)
    }

    // MARK: - Standard (Icon + Label)

    private var standardBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))

            Text(label)
                .font(AviationFont.severityBadge())
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Expanded (Full Banner)

    private var expandedBadge: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AviationFont.severityBadge())

                Text(description)
                    .font(AviationFont.caption())
                    .foregroundStyle(Color("TextSecondary"))
            }

            Spacer()
        }
        .foregroundStyle(color)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium)
                .stroke(color.opacity(0.35), lineWidth: 1)
        )
    }
}

// MARK: - Severity Dot Indicator

/// Simple colored dot indicator for severity
struct SeverityDot: View {
    let severity: NOTAMSeverity
    var size: CGFloat = 8
    var animated: Bool = false

    private var color: Color {
        switch severity {
        case .critical:
            return Color("CrimsonPulse")
        case .warning:
            return Color("AmberAlert")
        case .caution:
            return Color("CautionYellow")
        case .info:
            return Color("AuroraGreen")
        }
    }

    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .shadow(color: color.opacity(0.5), radius: animated && isPulsing ? 6 : 2)
            .scaleEffect(animated && isPulsing ? 1.2 : 1.0)
            .animation(
                animated ? AviationAnimation.pulse : nil,
                value: isPulsing
            )
            .onAppear {
                if animated && severity == .critical {
                    isPulsing = true
                }
            }
    }
}

// MARK: - Preview

#Preview("Severity Badges") {
    ScrollView {
        VStack(spacing: 24) {
            // Compact
            VStack(alignment: .leading, spacing: 12) {
                Text("Compact Style")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))

                HStack(spacing: 16) {
                    SeverityBadge(severity: .critical, style: .compact)
                    SeverityBadge(severity: .warning, style: .compact)
                    SeverityBadge(severity: .caution, style: .compact)
                    SeverityBadge(severity: .info, style: .compact)
                }
            }

            Divider()

            // Standard
            VStack(alignment: .leading, spacing: 12) {
                Text("Standard Style")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))

                VStack(spacing: 8) {
                    SeverityBadge(severity: .critical, style: .standard)
                    SeverityBadge(severity: .warning, style: .standard)
                    SeverityBadge(severity: .caution, style: .standard)
                    SeverityBadge(severity: .info, style: .standard)
                }
            }

            Divider()

            // Expanded
            VStack(alignment: .leading, spacing: 12) {
                Text("Expanded Style")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))

                VStack(spacing: 8) {
                    SeverityBadge(severity: .critical, style: .expanded)
                    SeverityBadge(severity: .warning, style: .expanded)
                }
            }

            Divider()

            // Dots
            VStack(alignment: .leading, spacing: 12) {
                Text("Dot Indicators")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))

                HStack(spacing: 16) {
                    SeverityDot(severity: .critical, animated: true)
                    SeverityDot(severity: .warning)
                    SeverityDot(severity: .caution)
                    SeverityDot(severity: .info)
                }
            }
        }
        .padding()
    }
    .background(Color("DeepSpace"))
}
