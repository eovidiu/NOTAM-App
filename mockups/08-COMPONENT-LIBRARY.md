# Premium Component Library

## Glass Card

The foundational container for all content.

```
┌─────────────────────────────────────────────────────────────────┐
│                        GLASS CARD                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Visual:                                                        │
│  ╔═══════════════════════════════════════════════════════════╗  │
│  ║                                                           ║  │
│  ║         Card content goes here                            ║  │
│  ║                                                           ║  │
│  ╚═══════════════════════════════════════════════════════════╝  │
│                                                                 │
│  Properties:                                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ background    │ Graphite (#1C1C28) @ 70% + ultraThinMaterial│
│  │ cornerRadius  │ 16pt continuous                           │  │
│  │ border        │ 1pt gradient (white 15% → 5%)             │  │
│  │ shadow        │ 0, 8, 24 black @ 30%                      │  │
│  │ padding       │ 16pt internal                             │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

SwiftUI Implementation:
```swift
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(.ultraThinMaterial)
            .background(Color.graphite.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.15), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 24, x: 0, y: 8)
    }
}
```

---

## Severity Badge

```
┌─────────────────────────────────────────────────────────────────┐
│                      SEVERITY BADGES                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  CRITICAL                                                       │
│  ┌──────────────────┐                                           │
│  │   ● CRITICAL     │  Background: Crimson @ 20%                │
│  └──────────────────┘  Border: Crimson @ 50%                    │
│                        Text: White, SF Pro Text Heavy, 10pt     │
│                        Glow: Crimson shadow (animated pulse)    │
│                                                                 │
│  WARNING                                                        │
│  ┌──────────────────┐                                           │
│  │   ● WARNING      │  Background: Amber @ 15%                  │
│  └──────────────────┘  Border: Amber @ 45%                      │
│                        Text: White                              │
│                                                                 │
│  CAUTION                                                        │
│  ┌──────────────────┐                                           │
│  │   ● CAUTION      │  Background: Yellow @ 12%                 │
│  └──────────────────┘  Border: Yellow @ 40%                     │
│                        Text: White                              │
│                                                                 │
│  INFO                                                           │
│  ┌──────────────────┐                                           │
│  │   ● INFO         │  Background: Green @ 12%                  │
│  └──────────────────┘  Border: Green @ 40%                      │
│                        Text: White                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

```swift
struct SeverityBadge: View {
    let severity: Severity

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(severity.color)
                .frame(width: 6, height: 6)

            Text(severity.rawValue.uppercased())
                .font(.system(size: 10, weight: .heavy))
                .tracking(1.2)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(severity.color.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(severity.color.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: severity == .critical ? severity.color.opacity(0.4) : .clear, radius: 8)
    }
}
```

---

## NOTAM ID Badge

```
┌─────────────────────────────────────────────────────────────────┐
│                      NOTAM ID BADGE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Compact (List View):                                           │
│  ┌────────────┐                                                 │
│  │   A0234    │    Size: 13pt SF Mono Bold                      │
│  │    /24     │    Background: Severity color @ 15%             │
│  └────────────┘    Border: Severity color @ 40%                 │
│                    Corner radius: 8pt                           │
│                    Size: ~60pt × ~44pt                          │
│                                                                 │
│  Hero (Detail View):                                            │
│  ┌──────────────────────┐                                       │
│  │                      │                                       │
│  │      A 0 2 3 4       │    Size: 32pt SF Mono Bold            │
│  │        / 2 4         │    Letter spacing: 4pt                │
│  │                      │    Background: Graphite + glow        │
│  │   ▓▓▓▓ CRITICAL ▓▓▓▓ │    Border: 2pt severity color         │
│  │                      │    Corner radius: 24pt                │
│  └──────────────────────┘    Size: ~180pt × ~160pt              │
│                              Shadow: Severity glow              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

```swift
struct NOTAMIDBadge: View {
    let id: String
    let severity: Severity
    let style: BadgeStyle // .compact or .hero

    var body: some View {
        VStack(spacing: style == .hero ? 12 : 2) {
            Text(id.prefix(5))
                .font(.system(
                    size: style == .hero ? 32 : 13,
                    weight: .bold,
                    design: .monospaced
                ))
                .tracking(style == .hero ? 4 : 0.5)

            Text("/" + id.suffix(2))
                .font(.system(
                    size: style == .hero ? 24 : 11,
                    weight: .medium,
                    design: .monospaced
                ))
                .foregroundStyle(.secondary)

            if style == .hero {
                SeverityBadge(severity: severity)
            }
        }
        .foregroundStyle(.white)
        .padding(style == .hero ? 24 : 8)
        .background(
            RoundedRectangle(cornerRadius: style == .hero ? 24 : 8, style: .continuous)
                .fill(severity.color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: style == .hero ? 24 : 8, style: .continuous)
                        .stroke(severity.color.opacity(style == .hero ? 0.6 : 0.4), lineWidth: style == .hero ? 2 : 1)
                )
        )
        .shadow(color: severity.color.opacity(0.3), radius: style == .hero ? 20 : 0)
    }
}
```

---

## FIR Code Pill

```
┌─────────────────────────────────────────────────────────────────┐
│                       FIR CODE PILL                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ╭──────────────╮                                               │
│  │    K J F K   │    Font: SF Mono Bold, 14pt                   │
│  ╰──────────────╯    Tracking: 2pt                              │
│                      Color: Electric Cyan                       │
│                      Background: Cyan @ 15%                     │
│                      Border: Cyan @ 40%                         │
│                      Padding: 12pt H, 6pt V                     │
│                      Corner: Capsule                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

```swift
struct FIRCodePill: View {
    let code: String

    var body: some View {
        Text(code)
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .tracking(2)
            .foregroundStyle(.electricCyan)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.electricCyan.opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(Color.electricCyan.opacity(0.4), lineWidth: 1)
                    )
            )
    }
}
```

---

## Section Header

```
┌─────────────────────────────────────────────────────────────────┐
│                      SECTION HEADER                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                                                         │    │
│  │   ▼   KJFK   ·   New York ARTCC                   12   │    │
│  │   │    │         │                                 │   │    │
│  │   │    │         │                                 │   │    │
│  │   │    │         │                              count  │    │
│  │   │    │         │                              badge  │    │
│  │   │    │         │                                     │    │
│  │   │    │         └─ Name: SF Pro Text, 15pt, Silver    │    │
│  │   │    │                                               │    │
│  │   │    └─ FIR Pill (see above)                         │    │
│  │   │                                                    │    │
│  │   └─ Chevron: chevron.right, rotates on expand         │    │
│  │                                                        │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  Background: Transparent (part of list)                         │
│  Tap area: Full width                                           │
│  Haptic: Light impact                                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

```swift
struct SectionHeader: View {
    let fir: FIR
    let count: Int
    @Binding var isExpanded: Bool

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.platinum)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))

                FIRCodePill(code: fir.code)

                Text("·")
                    .foregroundStyle(.platinum)

                Text(fir.name)
                    .font(.system(size: 15))
                    .foregroundStyle(.silver)

                Spacer()

                Text("\(count)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.electricCyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Circle()
                            .stroke(Color.electricCyan.opacity(0.4), lineWidth: 1)
                    )
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}
```

---

## Search Bar

```
┌─────────────────────────────────────────────────────────────────┐
│                       SEARCH BAR                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ╭─────────────────────────────────────────────────────────╮    │
│  │  🔍   Search NOTAMs...                              ✕   │    │
│  ╰─────────────────────────────────────────────────────────╯    │
│                                                                 │
│  Height: 44pt                                                   │
│  Corner radius: 12pt                                            │
│  Background: Slate Glass @ 50% + ultraThinMaterial              │
│  Border: 1pt white @ 15%                                        │
│  Icon: magnifyingglass, 16pt, Cyan                              │
│  Placeholder: SF Pro Text, 16pt, Platinum                       │
│  Clear button: xmark.circle.fill, appears when has text         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

```swift
struct PremiumSearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.electricCyan)

            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(.platinum))
                .font(.system(size: 16))
                .foregroundStyle(.white)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.platinum)
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(.ultraThinMaterial)
        .background(Color.slateGlass.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}
```

---

## Empty State

```
┌─────────────────────────────────────────────────────────────────┐
│                      EMPTY STATE                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│           ┌─────────────────────────────────────┐               │
│           │                                     │               │
│           │         ┌───────────────┐           │               │
│           │         │               │           │               │
│           │         │      🔔       │           │               │
│           │         │               │           │               │
│           │         └───────────────┘           │               │
│           │                                     │               │
│           │       No Changes Yet                │               │
│           │       ────────────────              │               │
│           │                                     │               │
│           │   Changes to your monitored         │               │
│           │   NOTAMs will appear here           │               │
│           │                                     │               │
│           │   ╭───────────────────────────╮     │               │
│           │   │     Add FIR to Monitor    │     │               │
│           │   ╰───────────────────────────╯     │               │
│           │                                     │               │
│           └─────────────────────────────────────┘               │
│                                                                 │
│  Icon: 56pt, Platinum, subtle float animation                   │
│  Title: SF Pro Display Semibold, 20pt, White                    │
│  Message: SF Pro Text Regular, 15pt, Platinum, multiline center │
│  Button (optional): Primary button style                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

```swift
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)?
    var actionTitle: String?

    @State private var iconOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(.platinum)
                .offset(y: iconOffset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        iconOffset = -8
                    }
                }

            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)

            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(.platinum)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            if let action, let actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.electricCyan)
                        )
                }
                .padding(.top, 8)
            }
        }
        .padding(32)
    }
}
```

---

## Progress Timeline Bar

```
┌─────────────────────────────────────────────────────────────────┐
│                   PROGRESS TIMELINE BAR                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  START                                              END         │
│  15 JAN 06:00                                  15 JAN 18:00     │
│                                                                 │
│  ████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │
│         ▲                                                       │
│        NOW                                                      │
│                                                                 │
│               ⏱ 5h 23m remaining                                │
│                                                                 │
│  Track: Slate Glass, 8pt height, 4pt radius                     │
│  Fill: Gradient (Cyan → Blue), animated on appear               │
│  Now indicator: Small inverted triangle                         │
│  Labels: SF Pro Text, 12pt, Platinum                            │
│  Remaining: SF Mono Medium, 16pt, changes color by urgency      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

```swift
struct TimelineProgressBar: View {
    let startDate: Date
    let endDate: Date

    var progress: Double {
        let total = endDate.timeIntervalSince(startDate)
        let elapsed = Date.now.timeIntervalSince(startDate)
        return min(max(elapsed / total, 0), 1)
    }

    var timeRemaining: TimeInterval {
        endDate.timeIntervalSince(Date.now)
    }

    var urgencyColor: Color {
        if timeRemaining < 2 * 3600 { return .crimsonPulse }
        if timeRemaining < 24 * 3600 { return .amber }
        return .electricCyan
    }

    var body: some View {
        VStack(spacing: 12) {
            // Labels
            HStack {
                VStack(alignment: .leading) {
                    Text("EFFECTIVE")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(0.5)
                        .foregroundStyle(.platinum)
                    Text(startDate.formatted())
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.silver)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("EXPIRES")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(0.5)
                        .foregroundStyle(.platinum)
                    Text(endDate.formatted())
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.silver)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.slateGlass)

                    // Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.electricCyan, .neonBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)

                    // Now indicator
                    Triangle()
                        .fill(Color.white)
                        .frame(width: 8, height: 6)
                        .offset(x: geo.size.width * progress - 4, y: -8)
                }
            }
            .frame(height: 8)

            // Time remaining
            HStack {
                Image(systemName: "timer")
                Text(formatDuration(timeRemaining))
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                Text("remaining")
            }
            .foregroundStyle(urgencyColor)
        }
    }
}
```
