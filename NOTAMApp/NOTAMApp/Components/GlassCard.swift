import SwiftUI

/// Aviation Glass Card Component
/// Premium glass morphism card with gradient border and subtle glow
struct GlassCard<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let content: Content
    var cornerRadius: CGFloat = AviationTheme.CornerRadius.large
    var padding: CGFloat = AviationTheme.Spacing.md
    var showBorder: Bool = true

    init(
        cornerRadius: CGFloat = AviationTheme.CornerRadius.large,
        padding: CGFloat = AviationTheme.Spacing.md,
        showBorder: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.showBorder = showBorder
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(borderOverlay)
    }

    @ViewBuilder
    private var backgroundView: some View {
        if reduceTransparency {
            // Solid fallback for accessibility
            Color("Graphite")
        } else {
            // Glass morphism effect
            ZStack {
                Color("Graphite")

                // Subtle gradient overlay for depth
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if showBorder {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
}

// MARK: - Elevated Glass Card Variant

/// Higher elevation glass card with stronger glow effect
struct ElevatedGlassCard<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let content: Content
    var cornerRadius: CGFloat = AviationTheme.CornerRadius.large
    var padding: CGFloat = AviationTheme.Spacing.md
    var glowColor: Color = Color("ElectricCyan")

    init(
        cornerRadius: CGFloat = AviationTheme.CornerRadius.large,
        padding: CGFloat = AviationTheme.Spacing.md,
        glowColor: Color = Color("ElectricCyan"),
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.glowColor = glowColor
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                reduceTransparency
                    ? AnyView(Color("SlateGlass"))
                    : AnyView(
                        ZStack {
                            Color("SlateGlass")
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: glowColor.opacity(reduceTransparency ? 0 : 0.15),
                radius: 20,
                x: 0,
                y: 10
            )
    }
}

// MARK: - Glass Background Modifier

struct GlassBackgroundModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var cornerRadius: CGFloat = AviationTheme.CornerRadius.medium
    var showBorder: Bool = true

    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if reduceTransparency {
                        Color("Graphite")
                    } else {
                        ZStack {
                            Color("Graphite")
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.05),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                Group {
                    if showBorder {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.white.opacity(0.04)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                }
            )
    }
}

extension View {
    /// Apply glass card background styling
    func glassBackground(
        cornerRadius: CGFloat = AviationTheme.CornerRadius.medium,
        showBorder: Bool = true
    ) -> some View {
        modifier(GlassBackgroundModifier(cornerRadius: cornerRadius, showBorder: showBorder))
    }
}

// MARK: - Preview

#Preview("Glass Cards") {
    ScrollView {
        VStack(spacing: 20) {
            Text("Glass Card")
                .font(.caption)
                .foregroundStyle(Color("TextTertiary"))

            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("A0234/24")
                        .font(AviationFont.notamId())
                        .foregroundStyle(Color("TextPrimary"))

                    Text("Runway 04L/22R Closed")
                        .font(AviationFont.cardTitle())
                        .foregroundStyle(Color("TextPrimary"))

                    Text("KJFK - New York JFK")
                        .font(AviationFont.bodySecondary())
                        .foregroundStyle(Color("TextSecondary"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text("Elevated Glass Card")
                .font(.caption)
                .foregroundStyle(Color("TextTertiary"))

            ElevatedGlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Critical Alert")
                        .font(AviationFont.cardTitle())
                        .foregroundStyle(Color("CrimsonPulse"))

                    Text("Airspace closure in effect")
                        .font(AviationFont.bodyPrimary())
                        .foregroundStyle(Color("TextSecondary"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text("Glass Background Modifier")
                .font(.caption)
                .foregroundStyle(Color("TextTertiary"))

            HStack {
                Text("Settings Item")
                    .font(AviationFont.bodyPrimary())
                    .foregroundStyle(Color("TextPrimary"))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("TextTertiary"))
            }
            .padding()
            .glassBackground()
        }
        .padding()
    }
    .background(Color("DeepSpace"))
}
