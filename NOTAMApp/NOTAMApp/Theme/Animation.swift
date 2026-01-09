import SwiftUI

/// Aviation Glass Animation System
/// Spring physics animations for premium, responsive feel
enum AviationAnimation {

    // MARK: - Spring Presets

    /// Instant feedback - 0.1s
    /// Usage: Immediate visual response to touches
    static let instant = Animation.easeOut(duration: 0.1)

    /// Quick transition - 0.2s spring
    /// Usage: Small element changes, toggles
    static let quick = Animation.spring(response: 0.2, dampingFraction: 0.8)

    /// Standard animation - 0.3s spring
    /// Usage: Most UI transitions
    static let standard = Animation.spring(response: 0.3, dampingFraction: 0.75)

    /// Emphasis animation - 0.4s spring
    /// Usage: Important state changes, modals
    static let emphasis = Animation.spring(response: 0.4, dampingFraction: 0.7)

    /// Page transition - 0.35s spring
    /// Usage: Navigation push/pop
    static let page = Animation.spring(response: 0.35, dampingFraction: 0.85)

    // MARK: - Specialized Animations

    /// Tab switch animation
    static let tabSwitch = Animation.spring(response: 0.25, dampingFraction: 0.85)

    /// Section expand/collapse
    static let expand = Animation.spring(response: 0.35, dampingFraction: 0.75)

    /// Card press effect
    static let cardPress = Animation.spring(response: 0.15, dampingFraction: 0.6)

    /// Toggle switch
    static let toggle = Animation.spring(response: 0.25, dampingFraction: 0.6)

    /// Button tap
    static let button = Animation.spring(response: 0.2, dampingFraction: 0.6)

    /// Badge bounce
    static let bounce = Animation.spring(response: 0.3, dampingFraction: 0.5)

    /// Hover effect (iPad)
    static let hover = Animation.spring(response: 0.2, dampingFraction: 0.8)

    // MARK: - Continuous Animations

    /// Shimmer effect - repeating
    static let shimmer = Animation.linear(duration: 1.5).repeatForever(autoreverses: false)

    /// Loading spinner - repeating
    static let spinner = Animation.linear(duration: 0.8).repeatForever(autoreverses: false)

    /// Pulse glow - repeating
    static let pulse = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)

    /// Notification pulse - one-way repeat
    static let notificationPulse = Animation.easeOut(duration: 1.0).repeatForever(autoreverses: false)

    // MARK: - Staggered Animation

    /// Create staggered delay for list items
    /// - Parameter index: Item index in the list
    /// - Parameter baseDelay: Base delay between items (default 0.05s)
    /// - Returns: Animation with calculated delay
    static func staggered(index: Int, baseDelay: Double = 0.05) -> Animation {
        standard.delay(Double(index) * baseDelay)
    }
}

// MARK: - Animation Extensions

extension Animation {
    /// Aviation standard spring
    static var aviationSpring: Animation {
        AviationAnimation.standard
    }

    /// Aviation quick spring
    static var aviationQuick: Animation {
        AviationAnimation.quick
    }

    /// Aviation bounce spring
    static var aviationBounce: Animation {
        AviationAnimation.bounce
    }
}

// MARK: - Transition Presets

extension AnyTransition {
    /// Staggered list item appear transition
    static var staggeredAppear: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9)
                .combined(with: .opacity)
                .combined(with: .offset(y: 20)),
            removal: .opacity
        )
    }

    /// Section content expand transition
    static var expandContent: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .top)),
            removal: .opacity
        )
    }

    /// Swipe action removal transition
    static var swipeRemoval: AnyTransition {
        .asymmetric(
            insertion: .identity,
            removal: .scale(scale: 0.8)
                .combined(with: .opacity)
                .combined(with: .offset(x: -50))
        )
    }

    /// Modal sheet transition
    static var sheetPresent: AnyTransition {
        .move(edge: .bottom)
    }

    /// Tab switch crossfade
    static func tabCrossfade(direction: CGFloat) -> AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(x: direction * 20)),
            removal: .opacity
        )
    }
}

// MARK: - View Modifiers

extension View {
    /// Apply staggered reveal animation
    /// - Parameters:
    ///   - index: Item index for stagger delay
    ///   - isVisible: Binding to visibility state
    func staggeredReveal(index: Int, isVisible: Binding<Bool>) -> some View {
        self
            .opacity(isVisible.wrappedValue ? 1 : 0)
            .offset(y: isVisible.wrappedValue ? 0 : 20)
            .scaleEffect(isVisible.wrappedValue ? 1 : 0.9)
            .animation(AviationAnimation.staggered(index: index), value: isVisible.wrappedValue)
    }

    /// Apply card press effect
    /// - Parameter isPressed: Whether card is currently pressed
    func cardPressEffect(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(AviationAnimation.cardPress, value: isPressed)
    }

    /// Apply hover glow effect (iPad)
    /// - Parameter isHovered: Whether view is hovered
    /// - Parameter glowColor: Color for the glow effect
    func hoverGlow(isHovered: Bool, glowColor: Color = Color("ElectricCyan")) -> some View {
        self
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(
                color: glowColor.opacity(isHovered ? 0.2 : 0),
                radius: isHovered ? 20 : 10
            )
            .animation(AviationAnimation.hover, value: isHovered)
    }

    /// Apply bounce effect on value change
    func bounceOnChange<V: Equatable>(value: V) -> some View {
        self.animation(AviationAnimation.bounce, value: value)
    }

    /// Conditionally apply animation based on reduce motion preference
    func animateUnlessReduceMotion<V: Equatable>(
        _ animation: Animation,
        value: V
    ) -> some View {
        self.modifier(ReduceMotionAnimationModifier(animation: animation, value: value))
    }
}

// MARK: - Reduce Motion Support

private struct ReduceMotionAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}

// MARK: - Preview

#Preview("Animation Timing") {
    AnimationDemoView()
}

private struct AnimationDemoView: View {
    @State private var isExpanded = false
    @State private var isPressed = false
    @State private var counter = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Expand/Collapse Demo
                VStack {
                    Button {
                        withAnimation(AviationAnimation.expand) {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.right")
                                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            Text("Expand Demo")
                        }
                    }

                    if isExpanded {
                        VStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("Graphite"))
                                    .frame(height: 40)
                                    .transition(.staggeredAppear)
                                    .animation(
                                        AviationAnimation.staggered(index: index),
                                        value: isExpanded
                                    )
                            }
                        }
                        .transition(.expandContent)
                    }
                }
                .padding()
                .background(Color("Obsidian"))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Card Press Demo
                VStack {
                    Text("Press Me")
                        .font(AviationFont.cardTitle())
                        .foregroundStyle(Color("TextPrimary"))
                        .padding()
                        .background(Color("Graphite"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .cardPressEffect(isPressed: isPressed)
                        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                            isPressed = pressing
                        }) {}
                }

                // Counter Demo
                VStack {
                    Text("\(counter)")
                        .font(AviationFont.counter())
                        .foregroundStyle(Color("ElectricCyan"))
                        .contentTransition(.numericText())
                        .animation(AviationAnimation.bounce, value: counter)

                    Button("Increment") {
                        counter += 1
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .background(Color("DeepSpace"))
    }
}
