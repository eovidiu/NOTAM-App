import SwiftUI

/// Aviation Glass Empty State View Component
/// Premium empty state with themed styling and optional action
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    let action: (() -> Void)?
    let actionTitle: String?

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: AviationTheme.Spacing.lg) {
            // Icon with subtle glow
            ZStack {
                // Glow background
                Circle()
                    .fill(Color("ElectricCyan").opacity(0.1))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)

                // Icon
                Image(systemName: systemImage)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color("TextTertiary"),
                                Color("TextDisabled")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            // Text Content
            VStack(spacing: AviationTheme.Spacing.xs) {
                Text(title)
                    .font(AviationFont.sectionHeader())
                    .foregroundStyle(Color("TextPrimary"))

                Text(message)
                    .font(AviationFont.bodySecondary())
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AviationTheme.Spacing.xl)
            }

            // Action Button
            if let action = action, let actionTitle = actionTitle {
                Button(action: {
                    HapticManager.shared.buttonTap()
                    action()
                }) {
                    HStack(spacing: 8) {
                        Text(actionTitle)
                            .font(AviationFont.cardTitle())

                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color("DeepSpace"))
                    .padding(.horizontal, AviationTheme.Spacing.lg)
                    .padding(.vertical, AviationTheme.Spacing.sm)
                    .background(
                        LinearGradient(
                            colors: [
                                Color("ElectricCyan"),
                                Color("ElectricCyan").opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color("ElectricCyan").opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AviationTheme.Spacing.lg)
        .onAppear {
            withAnimation(AviationAnimation.pulse) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Compact Empty State

/// Smaller empty state for inline use
struct CompactEmptyState: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: AviationTheme.Spacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(Color("TextDisabled"))

            VStack(spacing: 4) {
                Text(title)
                    .font(AviationFont.cardTitle())
                    .foregroundStyle(Color("TextSecondary"))

                Text(message)
                    .font(AviationFont.caption())
                    .foregroundStyle(Color("TextTertiary"))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AviationTheme.Spacing.lg)
    }
}

// MARK: - Preview

#Preview("Empty State") {
    EmptyStateView(
        title: "No NOTAMs",
        message: "Pull to refresh or configure FIRs in Settings",
        systemImage: "doc.text",
        action: {},
        actionTitle: "Refresh"
    )
    .background(Color("DeepSpace"))
}

#Preview("No Action") {
    EmptyStateView(
        title: "No Changes",
        message: "Changes will appear here when detected",
        systemImage: "bell.slash",
        action: nil,
        actionTitle: nil
    )
    .background(Color("DeepSpace"))
}

#Preview("Compact") {
    CompactEmptyState(
        title: "No Results",
        message: "Try a different search term",
        systemImage: "magnifyingglass"
    )
    .background(Color("DeepSpace"))
}
