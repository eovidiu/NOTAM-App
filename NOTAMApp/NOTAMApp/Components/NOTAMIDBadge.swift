import SwiftUI

/// NOTAM ID Badge Display Variants
enum NOTAMIDBadgeStyle {
    case compact   // Small inline badge
    case standard  // Normal badge with background
    case hero      // Large badge for detail view
}

/// Aviation Glass NOTAM ID Badge Component
/// Displays NOTAM identifier with monospace styling
struct NOTAMIDBadge: View {
    let id: String
    var style: NOTAMIDBadgeStyle = .standard

    var body: some View {
        switch style {
        case .compact:
            compactBadge
        case .standard:
            standardBadge
        case .hero:
            heroBadge
        }
    }

    // MARK: - Compact (Inline Text)

    private var compactBadge: some View {
        Text(id)
            .font(AviationFont.notamId())
            .foregroundStyle(Color("ElectricCyan"))
    }

    // MARK: - Standard (With Background)

    private var standardBadge: some View {
        Text(id)
            .font(AviationFont.notamId())
            .foregroundStyle(Color("ElectricCyan"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color("ElectricCyan").opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.small)
                    .stroke(Color("ElectricCyan").opacity(0.25), lineWidth: 1)
            )
    }

    // MARK: - Hero (Large for Detail View)

    private var heroBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 14, weight: .semibold))

            Text(id)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .tracking(1)
        }
        .foregroundStyle(Color("ElectricCyan"))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [
                    Color("ElectricCyan").opacity(0.15),
                    Color("ElectricCyan").opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color("ElectricCyan").opacity(0.4),
                            Color("ElectricCyan").opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color("ElectricCyan").opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview("NOTAM ID Badges") {
    VStack(spacing: 32) {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compact Style")
                .font(.caption)
                .foregroundStyle(Color("TextTertiary"))

            HStack(spacing: 16) {
                NOTAMIDBadge(id: "A0234/24", style: .compact)
                NOTAMIDBadge(id: "B1567/24", style: .compact)
            }
        }

        VStack(alignment: .leading, spacing: 12) {
            Text("Standard Style")
                .font(.caption)
                .foregroundStyle(Color("TextTertiary"))

            HStack(spacing: 12) {
                NOTAMIDBadge(id: "A0234/24", style: .standard)
                NOTAMIDBadge(id: "B1567/24", style: .standard)
            }
        }

        VStack(alignment: .leading, spacing: 12) {
            Text("Hero Style")
                .font(.caption)
                .foregroundStyle(Color("TextTertiary"))

            NOTAMIDBadge(id: "A0234/24", style: .hero)
        }
    }
    .padding()
    .background(Color("DeepSpace"))
}
