# NOTAM App Premium Redesign Mockups

## Overview

This folder contains comprehensive design mockups for a **premium, ultra-snappy** redesign of the NOTAM App. The design language is called **"Aviation Glass"** - inspired by modern cockpit displays and high-end automotive HUDs.

## Design Files

| File | Description |
|------|-------------|
| [00-DESIGN-VISION.md](./00-DESIGN-VISION.md) | Core design philosophy and brand essence |
| [01-COLOR-SYSTEM.md](./01-COLOR-SYSTEM.md) | Complete color palette with hex codes |
| [02-TYPOGRAPHY.md](./02-TYPOGRAPHY.md) | Type scale and font specifications |
| [03-SCREEN-NOTAMS-LIST.md](./03-SCREEN-NOTAMS-LIST.md) | Main NOTAMs list screen mockup |
| [04-SCREEN-NOTAM-DETAIL.md](./04-SCREEN-NOTAM-DETAIL.md) | NOTAM detail view mockup |
| [05-SCREEN-CHANGES.md](./05-SCREEN-CHANGES.md) | Changes/updates screen mockup |
| [06-SCREEN-SETTINGS.md](./06-SCREEN-SETTINGS.md) | Settings screen mockup |
| [07-ANIMATIONS-MICRO-INTERACTIONS.md](./07-ANIMATIONS-MICRO-INTERACTIONS.md) | Animation specs and haptic feedback |
| [08-COMPONENT-LIBRARY.md](./08-COMPONENT-LIBRARY.md) | Reusable component specifications |

---

## Quick Reference

### Color Palette

```
BACKGROUNDS
━━━━━━━━━━━━
Deep Space    #0A0A0F    Base background
Obsidian      #12121A    Primary surface
Graphite      #1C1C28    Elevated cards
Slate Glass   #252535    Interactive elements

ACCENTS
━━━━━━━━
Electric Cyan #00D4FF    Primary accent
Neon Blue     #4D9FFF    Links, interactive
Aurora Green  #00FF94    Success, safe
Amber Alert   #FFB800    Warning, caution
Crimson Pulse #FF3366    Critical, danger
```

### Animation Timing

```
Instant feedback     0.1s   easeOut
Quick transition     0.2s   spring(0.5, 0.8)
Standard animation   0.3s   spring(0.5, 0.75)
Emphasis animation   0.4s   spring(0.6, 0.7)
Page transition      0.35s  spring(0.5, 0.85)
```

### Key Design Principles

1. **Dark-First** - Optimized for night/cockpit use
2. **Glass Morphism** - Layered translucent surfaces
3. **Precision Typography** - Technical, readable fonts
4. **Micro-interactions** - Every tap responds instantly
5. **Haptic Feedback** - Premium tactile response

---

## Visual Preview

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│     N O T A M s                                     ⟳  ●    │
│     23 Active                                               │
│     ╭────────────────────────────────────────────────╮      │
│     │ 🔍  Search NOTAMs...                           │      │
│     ╰────────────────────────────────────────────────╯      │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ ▼  KJFK  ·  New York ARTCC                       12 ▸  │  │
│  │                                                        │  │
│  │    ╔════════════════════════════════════════════════╗  │  │
│  │    ║  ┌──────┐                                      ║  │  │
│  │    ║  │A0234 │  RWY 04L/22R CLSD                   ║  │  │
│  │    ║  │ /24  │  Runway closed for maintenance      ║  │  │
│  │    ║  └──────┘  📍 JFK · ✈️ Runway · 5h remaining   ║  │  │
│  │    ║   🔴 CRIT                                      ║  │  │
│  │    ╚════════════════════════════════════════════════╝  │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│     ┌─────────┐      ┌─────────┐      ┌─────────┐           │
│     │ ✈️      │      │  🔄     │      │  ⚙️     │           │
│     │ NOTAMs  │      │ Changes │      │Settings │           │
│     │  ════   │      │   (3)   │      │         │           │
│     └─────────┘      └─────────┘      └─────────┘           │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Target Feel

> When users open the app, they should feel like they're accessing a **professional-grade aviation tool** - the same quality as instruments in a modern cockpit. Every interaction should feel **precise, responsive, and satisfying**.

**Think:** Porsche Taycan dashboard meets Apple Watch Ultra meets ForeFlight Pro

---

## Implementation Notes

- All mockups include SwiftUI code snippets ready for implementation
- Animations use iOS 17+ APIs (spring physics, contentTransition)
- Haptics are specified for all interactive elements
- Dark mode is primary; light mode adaptation included
- Accessibility considerations (reduce motion, VoiceOver) addressed

---

## Next Steps

1. **Review mockups** - Share feedback on visual direction
2. **Approve color palette** - Finalize the "Midnight Aviation" palette
3. **Prioritize screens** - Which screen to implement first?
4. **Create design tokens** - Extract into SwiftUI Theme system
5. **Implement incrementally** - Start with component library

---

*Created: January 2026*
*Design System: Aviation Glass v1.0*
