# Animations & Micro-Interactions

## Core Animation Philosophy

> **"Snappy = Responsive + Satisfying"**
> Every interaction should feel instant while still being delightful.

### Timing Guidelines

| Interaction Type | Duration | Curve |
|-----------------|----------|-------|
| Instant feedback | 0.1s | easeOut |
| Quick transition | 0.2s | spring(0.5, 0.8) |
| Standard animation | 0.3s | spring(0.5, 0.75) |
| Emphasis animation | 0.4s | spring(0.6, 0.7) |
| Page transition | 0.35s | spring(0.5, 0.85) |

---

## Haptic Feedback Map

```swift
// CRITICAL: Haptics make the app feel premium and responsive

enum AppHaptics {
    // Navigation
    static let tabSwitch = UIImpactFeedbackGenerator(style: .light)
    static let pageTransition = UIImpactFeedbackGenerator(style: .soft)

    // Interactions
    static let buttonTap = UIImpactFeedbackGenerator(style: .light)
    static let toggleSwitch = UIImpactFeedbackGenerator(style: .medium)
    static let pullToRefresh = UIImpactFeedbackGenerator(style: .medium)

    // Feedback
    static let success = UINotificationFeedbackGenerator().notificationOccurred(.success)
    static let warning = UINotificationFeedbackGenerator().notificationOccurred(.warning)
    static let error = UINotificationFeedbackGenerator().notificationOccurred(.error)

    // Drag & Drop
    static let pickUp = UIImpactFeedbackGenerator(style: .medium)
    static let drop = UIImpactFeedbackGenerator(style: .light)

    // Selection
    static let selectionChanged = UISelectionFeedbackGenerator().selectionChanged()
}
```

---

## Screen Transitions

### Tab Switch
```swift
// Crossfade with subtle slide
.transition(.asymmetric(
    insertion: .opacity.combined(with: .offset(x: direction * 20)),
    removal: .opacity
))
.animation(.spring(response: 0.25, dampingFraction: 0.85))

// Tab icon bounce
withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
    selectedTab = newTab
}
// Icon scales 1.0 → 1.15 → 1.0
```

### Navigation Push/Pop
```swift
// Custom push: slide + scale + fade
.transition(.asymmetric(
    insertion: .move(edge: .trailing)
        .combined(with: .scale(scale: 0.95))
        .combined(with: .opacity),
    removal: .move(edge: .leading)
        .combined(with: .scale(scale: 0.95))
        .combined(with: .opacity)
))
.animation(.spring(response: 0.35, dampingFraction: 0.85))
```

### Modal Present
```swift
// Sheet rises with bounce
.transition(.move(edge: .bottom))
.animation(.spring(response: 0.4, dampingFraction: 0.8))

// Background dims with blur
.background(
    Color.black
        .opacity(isPresented ? 0.5 : 0)
        .animation(.easeOut(duration: 0.25))
)
```

---

## List Animations

### Staggered Appear
```swift
ForEach(Array(items.enumerated()), id: \.1.id) { index, item in
    ItemRow(item: item)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9)
                .combined(with: .opacity)
                .combined(with: .offset(y: 20)),
            removal: .opacity
        ))
        .animation(
            .spring(response: 0.4, dampingFraction: 0.75)
                .delay(Double(index) * 0.05),
            value: items
        )
}
```

### Section Expand/Collapse
```swift
// Chevron rotation
Image(systemName: "chevron.right")
    .rotationEffect(.degrees(isExpanded ? 90 : 0))
    .animation(.spring(response: 0.3, dampingFraction: 0.7))

// Content reveal
if isExpanded {
    VStack {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
    .transition(.asymmetric(
        insertion: .opacity.combined(with: .move(edge: .top)),
        removal: .opacity
    ))
}
// Use withAnimation(.spring(response: 0.35, dampingFraction: 0.75))
```

### Pull to Refresh
```swift
// Custom refresh view
struct PremiumRefreshView: View {
    @Binding var isRefreshing: Bool

    var body: some View {
        Image(systemName: "airplane")
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(.electricCyan)
            .rotationEffect(.degrees(isRefreshing ? 360 : 0))
            .animation(
                isRefreshing
                    ? .linear(duration: 1).repeatForever(autoreverses: false)
                    : .default,
                value: isRefreshing
            )
            .scaleEffect(isRefreshing ? 1.1 : 1.0)
            .animation(.spring(response: 0.3), value: isRefreshing)
    }
}
```

### Swipe Actions
```swift
// Swipe reveal with spring
.swipeActions(edge: .trailing, allowsFullSwipe: true) {
    Button(role: .destructive) {
        // Delete with haptic
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            deleteItem(item)
        }
    } label: {
        Label("Delete", systemImage: "trash.fill")
    }
}

// Item removal animation
.transition(.asymmetric(
    insertion: .identity,
    removal: .scale(scale: 0.8)
        .combined(with: .opacity)
        .combined(with: .offset(x: -50))
))
```

---

## Card Interactions

### Card Press
```swift
struct PressableCard: View {
    @State private var isPressed = false

    var body: some View {
        CardContent()
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                isPressed = pressing
                if pressing {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }) { }
    }
}
```

### Card Hover/Focus (iPad)
```swift
.hoverEffect(.lift) // System hover
// Or custom:
.onHover { hovering in
    withAnimation(.spring(response: 0.2)) {
        isHovered = hovering
    }
}
.scaleEffect(isHovered ? 1.02 : 1.0)
.shadow(
    color: .electricCyan.opacity(isHovered ? 0.2 : 0),
    radius: isHovered ? 20 : 10
)
```

---

## Button Animations

### Primary Button
```swift
struct PremiumButton: View {
    @State private var isPressed = false

    var body: some View {
        Text("Action")
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.electricCyan, .neonBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .electricCyan.opacity(isPressed ? 0.3 : 0.5), radius: isPressed ? 5 : 15)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
    }
}
```

### Icon Button (Toolbar)
```swift
Image(systemName: "arrow.clockwise")
    .symbolEffect(.bounce, value: isRefreshing)
    .rotationEffect(.degrees(isRefreshing ? 360 : 0))
    .animation(
        isRefreshing
            ? .linear(duration: 0.8).repeatForever(autoreverses: false)
            : .spring(response: 0.3),
        value: isRefreshing
    )
```

---

## Toggle Switch Animation

```swift
struct PremiumToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        ZStack {
            // Track
            Capsule()
                .fill(isOn ? Color.electricCyan : Color.graphite)
                .frame(width: 51, height: 31)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

            // Thumb
            Circle()
                .fill(.white)
                .frame(width: 27, height: 27)
                .shadow(color: isOn ? .electricCyan.opacity(0.3) : .black.opacity(0.2), radius: 4)
                .offset(x: isOn ? 10 : -10)
        }
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                isOn.toggle()
            }
        }
    }
}
```

---

## Loading States

### Skeleton Shimmer
```swift
struct SkeletonView: View {
    @State private var shimmerOffset: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.slate)
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.1),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: shimmerOffset * 200)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmerOffset = 1
                }
            }
    }
}
```

### Progress Indicator
```swift
struct PremiumProgress: View {
    @State private var rotation: Double = 0

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                AngularGradient(
                    colors: [.electricCyan.opacity(0), .electricCyan],
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .frame(width: 24, height: 24)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}
```

---

## Notification Badge

### Bounce on Update
```swift
Text("\(count)")
    .font(.system(size: 10, weight: .bold))
    .foregroundStyle(.white)
    .padding(6)
    .background(Circle().fill(.crimsonPulse))
    .contentTransition(.numericText())
    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: count)
    // Badge bounces when count increases
```

### Pulse Animation
```swift
Circle()
    .fill(.crimsonPulse)
    .frame(width: 8, height: 8)
    .overlay(
        Circle()
            .stroke(.crimsonPulse, lineWidth: 2)
            .scaleEffect(isPulsing ? 2 : 1)
            .opacity(isPulsing ? 0 : 1)
    )
    .onAppear {
        withAnimation(.easeOut(duration: 1).repeatForever(autoreverses: false)) {
            isPulsing = true
        }
    }
```

---

## Severity Indicator Glow

### Critical Pulse
```swift
struct CriticalGlow: View {
    @State private var glowRadius: CGFloat = 10

    var body: some View {
        content
            .shadow(color: .crimsonPulse.opacity(0.5), radius: glowRadius)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowRadius = 20
                }
            }
    }
}
```

---

## Number Transitions

### Counter Animation
```swift
Text("\(count)")
    .contentTransition(.numericText(countsDown: count < previousCount))
    .animation(.spring(response: 0.3), value: count)
    .font(.system(size: 48, weight: .bold, design: .rounded))
    .monospacedDigit() // Prevents layout shift
```

### Countdown Timer
```swift
TimelineView(.periodic(from: .now, by: 1)) { _ in
    Text(formatTimeRemaining(endDate))
        .contentTransition(.numericText())
        .animation(.spring(response: 0.2), value: Date.now)
}
```

---

## Performance Notes

```swift
// Use transactions for grouped animations
var transaction = Transaction(animation: .spring(response: 0.3))
transaction.disablesAnimations = false
withTransaction(transaction) {
    // Multiple state changes animate together
}

// Disable animations for rapid updates
withAnimation(nil) {
    // Instant update
}

// Use .drawingGroup() for complex views
ComplexAnimatedView()
    .drawingGroup()

// Reduce motion support
@Environment(\.accessibilityReduceMotion) var reduceMotion

withAnimation(reduceMotion ? nil : .spring()) {
    // Animation
}
```
