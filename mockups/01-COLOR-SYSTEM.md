# Premium Color System

## Primary Palette: "Midnight Aviation"

### Dark Mode (Primary)

```
┌─────────────────────────────────────────────────────────────────┐
│  BACKGROUND LAYERS                                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Deep Space        #0A0A0F     ████████  Base background        │
│  Obsidian          #12121A     ████████  Primary surface        │
│  Graphite          #1C1C28     ████████  Elevated cards         │
│  Slate Glass       #252535     ████████  Interactive elements   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  ACCENT COLORS                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Electric Cyan     #00D4FF     ████████  Primary accent         │
│  Neon Blue         #4D9FFF     ████████  Links, interactive     │
│  Aurora Green      #00FF94     ████████  Success, safe          │
│  Amber Alert       #FFB800     ████████  Warning, caution       │
│  Crimson Pulse     #FF3366     ████████  Critical, danger       │
│  Violet Glow       #9D4EDD     ████████  Special highlights     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  TEXT HIERARCHY                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Pure White        #FFFFFF     ████████  Headlines, emphasis    │
│  Silver            #E5E5EA     ████████  Primary text           │
│  Platinum          #A1A1AA     ████████  Secondary text         │
│  Graphite Text     #6B6B7A     ████████  Tertiary/disabled      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Severity Color System (Enhanced)

### Critical Severity
```
Background:  rgba(255, 51, 102, 0.15)   Subtle red glow
Border:      rgba(255, 51, 102, 0.40)   Glowing edge
Icon:        #FF3366                     Solid crimson
Pulse:       Animated glow effect        0.5s ease-in-out loop
```

### Warning Severity
```
Background:  rgba(255, 184, 0, 0.12)    Subtle amber
Border:      rgba(255, 184, 0, 0.35)    Warm edge
Icon:        #FFB800                     Solid amber
```

### Caution Severity
```
Background:  rgba(255, 214, 0, 0.10)    Pale yellow
Border:      rgba(255, 214, 0, 0.30)    Soft edge
Icon:        #FFD600                     Bright yellow
```

### Info Severity
```
Background:  rgba(0, 255, 148, 0.10)    Subtle green
Border:      rgba(0, 255, 148, 0.30)    Fresh edge
Icon:        #00FF94                     Aurora green
```

---

## Gradient Definitions

### Header Gradient (Mesh)
```swift
MeshGradient(
    width: 3, height: 3,
    points: [
        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
    ],
    colors: [
        .deepSpace, .obsidian, .deepSpace,
        .obsidian, Color(hex: "1a1a2e"), .obsidian,
        .deepSpace, .obsidian, .deepSpace
    ]
)
```

### Card Glow Gradient
```swift
LinearGradient(
    colors: [
        Color.white.opacity(0.08),
        Color.white.opacity(0.02),
        Color.clear
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### Accent Shimmer
```swift
LinearGradient(
    colors: [
        Color.electricCyan.opacity(0.0),
        Color.electricCyan.opacity(0.3),
        Color.electricCyan.opacity(0.0)
    ],
    startPoint: .leading,
    endPoint: .trailing
)
// Animated: translateX from -100% to 100% over 2s
```

---

## Glass Morphism Specs

### Primary Glass Card
```swift
.background(.ultraThinMaterial)
.background(Color.graphite.opacity(0.5))
.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: 16, style: .continuous)
        .stroke(
            LinearGradient(
                colors: [.white.opacity(0.2), .white.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 1
        )
)
.shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
```

### Elevated Glass (Modals)
```swift
.background(.regularMaterial)
.background(Color.slate.opacity(0.7))
.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: 24, style: .continuous)
        .stroke(.white.opacity(0.15), lineWidth: 1)
)
.shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 20)
```

---

## Light Mode Adaptation

When light mode is enabled (pilot preference for daytime):

```
Deep Space    →  #FAFAFA (Off-white)
Obsidian      →  #FFFFFF (Pure white)
Graphite      →  #F5F5F7 (Apple gray)
Slate Glass   →  #EBEBF0 (Light gray)

Text colors invert appropriately
Accents remain vibrant but slightly desaturated
Glass effects use .thinMaterial instead
```
