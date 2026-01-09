import SwiftUI
import UIKit

/// Aviation Glass Haptic Feedback System
/// Premium tactile responses for all interactions
@MainActor
final class HapticManager {
    static let shared = HapticManager()

    // MARK: - Feedback Generators

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        prepareAll()
    }

    // MARK: - Preparation

    /// Pre-warm generators for lower latency on first use
    func prepareAll() {
        impactLight.prepare()
        impactMedium.prepare()
        impactSoft.prepare()
        selection.prepare()
        notification.prepare()
    }

    // MARK: - Impact Feedback

    /// Light impact - Tab switch, button tap
    func light() {
        impactLight.impactOccurred()
    }

    /// Medium impact - Toggle switch, pull to refresh
    func medium() {
        impactMedium.impactOccurred()
    }

    /// Heavy impact - Destructive actions
    func heavy() {
        impactHeavy.impactOccurred()
    }

    /// Soft impact - Page transitions
    func soft() {
        impactSoft.impactOccurred()
    }

    /// Rigid impact - Hard boundaries
    func rigid() {
        impactRigid.impactOccurred()
    }

    /// Impact with custom intensity (0.0 - 1.0)
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1.0) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred(intensity: intensity)
    }

    // MARK: - Selection Feedback

    /// Selection changed - List item selection, picker changes
    func selectionChanged() {
        selection.selectionChanged()
    }

    // MARK: - Notification Feedback

    /// Success - Action completed successfully
    func success() {
        notification.notificationOccurred(.success)
    }

    /// Warning - Attention needed
    func warning() {
        notification.notificationOccurred(.warning)
    }

    /// Error - Action failed
    func error() {
        notification.notificationOccurred(.error)
    }

    // MARK: - Contextual Haptics

    /// Tab switch haptic
    func tabSwitch() {
        light()
    }

    /// Page transition haptic
    func pageTransition() {
        soft()
    }

    /// Button tap haptic
    func buttonTap() {
        light()
    }

    /// Toggle switch haptic
    func toggleSwitch() {
        medium()
    }

    /// Pull to refresh haptic
    func pullToRefresh() {
        medium()
    }

    /// Drag pickup haptic
    func dragPickup() {
        medium()
    }

    /// Drag drop haptic
    func dragDrop() {
        light()
    }

    /// Card press haptic
    func cardPress() {
        light()
    }

    /// Section expand/collapse haptic
    func sectionToggle() {
        light()
    }

    /// Critical alert haptic
    func criticalAlert() {
        notification.notificationOccurred(.warning)
    }
}

// MARK: - View Extension for Easy Haptics

extension View {
    /// Add haptic feedback on tap
    func hapticOnTap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    Task { @MainActor in
                        HapticManager.shared.impact(style: style)
                    }
                }
        )
    }

    /// Add haptic feedback when value changes
    func hapticOnChange<V: Equatable>(
        of value: V,
        perform: @escaping (V) -> UIImpactFeedbackGenerator.FeedbackStyle?
    ) -> some View {
        self.onChange(of: value) { _, newValue in
            if let style = perform(newValue) {
                Task { @MainActor in
                    HapticManager.shared.impact(style: style)
                }
            }
        }
    }
}

// MARK: - Haptic Feedback Modifier

struct HapticFeedbackModifier: ViewModifier {
    let style: UIImpactFeedbackGenerator.FeedbackStyle
    let trigger: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    Task { @MainActor in
                        HapticManager.shared.impact(style: style)
                    }
                }
            }
    }
}

extension View {
    /// Trigger haptic feedback when condition becomes true
    func hapticFeedback(
        _ style: UIImpactFeedbackGenerator.FeedbackStyle,
        trigger: Bool
    ) -> some View {
        modifier(HapticFeedbackModifier(style: style, trigger: trigger))
    }
}

// MARK: - Haptic Button Style

struct HapticButtonStyle: ButtonStyle {
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle

    init(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        self.hapticStyle = style
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(AviationAnimation.button, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    Task { @MainActor in
                        HapticManager.shared.impact(style: hapticStyle)
                    }
                }
            }
    }
}

extension ButtonStyle where Self == HapticButtonStyle {
    /// Button style with haptic feedback
    static var haptic: HapticButtonStyle { HapticButtonStyle() }

    /// Button style with custom haptic intensity
    static func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) -> HapticButtonStyle {
        HapticButtonStyle(style)
    }
}

// MARK: - Preview

#Preview("Haptic Demo") {
    VStack(spacing: 20) {
        Text("Haptic Feedback Demo")
            .font(.headline)

        Button("Light Impact") {
            Task { @MainActor in
                HapticManager.shared.light()
            }
        }
        .buttonStyle(.haptic)

        Button("Medium Impact") {
            Task { @MainActor in
                HapticManager.shared.medium()
            }
        }
        .buttonStyle(.haptic(.medium))

        Button("Success Notification") {
            Task { @MainActor in
                HapticManager.shared.success()
            }
        }
        .buttonStyle(.borderedProminent)

        Button("Warning Notification") {
            Task { @MainActor in
                HapticManager.shared.warning()
            }
        }
        .buttonStyle(.bordered)

        Button("Error Notification") {
            Task { @MainActor in
                HapticManager.shared.error()
            }
        }
        .buttonStyle(.bordered)
        .tint(.red)
    }
    .padding()
}
