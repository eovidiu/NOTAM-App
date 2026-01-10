import SwiftUI

/// Aviation Glass Section Header Component
/// Collapsible section header with FIR code and NOTAM count
struct SectionHeader: View {
    let code: String
    var name: String? = nil
    var count: Int = 0
    var isExpanded: Bool = true
    var onToggle: (() -> Void)? = nil

    var body: some View {
        Button(action: { onToggle?() }) {
            HStack(spacing: 12) {
                // Chevron indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color("TextTertiary"))
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))

                // FIR Code with glow
                Text(code)
                    .font(AviationFont.firCode())
                    .foregroundStyle(Color("TextPrimary"))

                // FIR Name (if provided)
                if let name = name {
                    Text(name)
                        .font(AviationFont.bodySecondary())
                        .foregroundStyle(Color("TextSecondary"))
                        .lineLimit(1)
                }

                Spacer()

                // NOTAM Count Badge
                if count > 0 {
                    Text("\(count)")
                        .font(AviationFont.notamId())
                        .foregroundStyle(Color("ElectricCyan"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color("ElectricCyan").opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, AviationTheme.Spacing.md)
            .padding(.vertical, AviationTheme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(AviationAnimation.quick, value: isExpanded)
    }
}

// MARK: - Simple Section Header (Non-Collapsible)

struct SimpleSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var action: (() -> Void)? = nil
    var actionLabel: String? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AviationFont.label())
                    .foregroundStyle(Color("TextTertiary"))

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AviationFont.caption())
                        .foregroundStyle(Color("TextDisabled"))
                }
            }

            Spacer()

            if let action = action, let label = actionLabel {
                Button(action: action) {
                    Text(label)
                        .font(AviationFont.bodySecondary())
                        .foregroundStyle(Color("ElectricCyan"))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AviationTheme.Spacing.md)
        .padding(.vertical, AviationTheme.Spacing.xs)
    }
}

// MARK: - Gradient Header (Hero)

struct GradientHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AviationFont.heroTitle())
                .foregroundStyle(Color("TextPrimary"))

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AviationFont.bodySecondary())
                    .foregroundStyle(Color("TextSecondary"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AviationTheme.Spacing.md)
        .padding(.vertical, AviationTheme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    Color("ElectricCyan").opacity(0.15),
                    Color("DeepSpace")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Preview

#Preview("Section Headers") {
    ScrollView {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Collapsible Section Header")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))
                    .padding(.horizontal)

                SectionHeader(
                    code: "KJFK",
                    name: "New York JFK",
                    count: 12,
                    isExpanded: true
                )
                .background(Color("Obsidian"))

                SectionHeader(
                    code: "KLAX",
                    name: "Los Angeles",
                    count: 5,
                    isExpanded: false
                )
                .background(Color("Obsidian"))
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Simple Section Header")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))
                    .padding(.horizontal)

                SimpleSectionHeader(
                    title: "NOTIFICATIONS",
                    subtitle: "Configure alerts"
                )

                SimpleSectionHeader(
                    title: "CONFIGURED FIRS",
                    action: {},
                    actionLabel: "Add"
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Gradient Header")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))
                    .padding(.horizontal)

                GradientHeader(
                    title: "NOTAMs",
                    subtitle: "23 Active"
                )
            }
        }
    }
    .background(Color("DeepSpace"))
}
