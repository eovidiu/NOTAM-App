# Premium Typography System

## Font Stack

### Primary: SF Pro Display
Used for headlines, large numbers, and emphasis.

### Secondary: SF Pro Text
Used for body copy and UI elements.

### Monospace: SF Mono
Used for NOTAM IDs, codes, timestamps, and raw data.

---

## Type Scale

```
┌─────────────────────────────────────────────────────────────────┐
│  DISPLAY                                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Hero Title                                                     │
│  Font: SF Pro Display Bold                                      │
│  Size: 34pt / Line: 41pt / Tracking: -0.4                       │
│  Usage: Main screen titles                                      │
│                                                                 │
│  ░░ NOTAMs ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  HEADLINES                                                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Section Header                                                 │
│  Font: SF Pro Display Semibold                                  │
│  Size: 22pt / Line: 28pt / Tracking: -0.26                      │
│  Usage: FIR group headers, modal titles                         │
│                                                                 │
│  ░░ KJFK - New York ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│                                                                 │
│  Card Title                                                     │
│  Font: SF Pro Text Semibold                                     │
│  Size: 17pt / Line: 22pt / Tracking: -0.4                       │
│  Usage: NOTAM titles, list item headers                         │
│                                                                 │
│  ░░ Runway 04L/22R Closed ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  BODY                                                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Body Primary                                                   │
│  Font: SF Pro Text Regular                                      │
│  Size: 16pt / Line: 22pt / Tracking: 0                          │
│  Usage: Main content, descriptions                              │
│                                                                 │
│  Body Secondary                                                 │
│  Font: SF Pro Text Regular                                      │
│  Size: 14pt / Line: 19pt / Tracking: 0                          │
│  Color: Platinum (#A1A1AA)                                      │
│  Usage: Supporting text, metadata                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  TECHNICAL / DATA                                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  NOTAM ID Badge                                                 │
│  Font: SF Mono Bold                                             │
│  Size: 13pt / Tracking: 0.5                                     │
│  Style: ALL CAPS                                                │
│                                                                 │
│  ░░ A0234/24 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│                                                                 │
│  Timestamp                                                      │
│  Font: SF Mono Medium                                           │
│  Size: 12pt / Tracking: 0.3                                     │
│  Color: Platinum                                                │
│                                                                 │
│  ░░ 2024-01-15 14:32 UTC ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│                                                                 │
│  Raw NOTAM Text                                                 │
│  Font: SF Mono Regular                                          │
│  Size: 14pt / Line: 20pt                                        │
│  Background: Obsidian with slight blue tint                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  LABELS & CAPTIONS                                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Label                                                          │
│  Font: SF Pro Text Medium                                       │
│  Size: 12pt / Tracking: 0.5                                     │
│  Style: ALL CAPS                                                │
│  Color: Platinum                                                │
│                                                                 │
│  ░░ EFFECTIVE ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│                                                                 │
│  Caption                                                        │
│  Font: SF Pro Text Regular                                      │
│  Size: 11pt / Line: 13pt                                        │
│  Color: Graphite Text                                           │
│                                                                 │
│  ░░ Last updated 5 minutes ago ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Special Typography Treatments

### Severity Badge Text
```swift
Text("CRITICAL")
    .font(.system(size: 10, weight: .heavy, design: .rounded))
    .tracking(1.2)
    .foregroundStyle(.white)
    .shadow(color: .crimsonPulse.opacity(0.5), radius: 4)
```

### Animated Counter (NOTAM count)
```swift
Text("\(count)")
    .font(.system(size: 48, weight: .bold, design: .rounded))
    .contentTransition(.numericText())
    .foregroundStyle(
        LinearGradient(
            colors: [.electricCyan, .neonBlue],
            startPoint: .top,
            endPoint: .bottom
        )
    )
```

### FIR Code Display
```swift
Text("KJFK")
    .font(.system(size: 18, weight: .bold, design: .monospaced))
    .tracking(2)
    .foregroundStyle(.white)
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(
        Capsule()
            .fill(Color.electricCyan.opacity(0.2))
            .overlay(
                Capsule()
                    .stroke(Color.electricCyan.opacity(0.5), lineWidth: 1)
            )
    )
```

---

## Typographic Rhythm

Consistent spacing based on 4pt grid:

```
Section gap:      32pt (8 × 4)
Card gap:         16pt (4 × 4)
Internal padding: 16pt (4 × 4)
Text stack gap:   8pt  (2 × 4)
Inline gap:       4pt  (1 × 4)
```
