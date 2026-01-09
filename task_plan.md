# Task Plan: Aviation Glass Design System Implementation

## Goal
Implement the "Aviation Glass" premium design system - a dark-first UI inspired by modern cockpit displays.

## Design Decisions
- **Approach:** Full Aviation Glass (implement mockups exactly)
- **Platform:** iPhone only (standard tab bar navigation)
- **Accessibility:** Reduce Motion and Increase Contrast fallbacks in Phase 4

## Implementation Phases

### Phase 1: Foundation
- [x] Create Theme/ folder structure
- [x] Add 17 colors to Asset Catalog (dark + light variants)
- [x] Create AviationTheme.swift with @Observable
- [x] Create Typography.swift with 13 font functions
- [x] Create Animation.swift with spring presets
- [x] Create HapticManager.swift singleton
- [x] Build verification: **PASSED**
- [x] Commit: 3e32196

### Phase 2: Components (Next)
- [ ] Build GlassCard (with glass/solid toggle)
- [ ] Build SeverityBadge (compact/standard/expanded)
- [ ] Build NOTAMIDBadge (compact/hero variants)
- [ ] Build FIRCodePill
- [ ] Build SectionHeader (collapsible, uses theme)
- [ ] Build PremiumSearchBar
- [ ] Build TimelineProgressBar
- [ ] Update EmptyStateView to use theme

### Phase 3: View Migration
- [ ] Migrate NOTAMRowView (uses new components)
- [ ] Migrate NOTAMDetailView
- [ ] Migrate NOTAMListView (sections, search)
- [ ] Migrate ChangesListView
- [ ] Migrate ChangeDetailView
- [ ] Migrate SettingsView
- [ ] Migrate ContentView (tab bar styling)

### Phase 4: Polish
- [ ] Add staggered reveal animations
- [ ] Add haptic feedback to key interactions
- [ ] Implement Reduce Motion support
- [ ] Implement Increase Contrast fallbacks
- [ ] Performance testing with glass effects
- [ ] Test on older devices (iPhone 12 minimum)

### Phase 5: Accessibility Audit
- [ ] VoiceOver walkthrough
- [ ] Dynamic Type scaling verification
- [ ] Color contrast validation
- [ ] Bold Text support check

## Status
**Phase 1 Complete** - Foundation built and committed. Ready for Phase 2: Components.

## Plan File
Full plan with architecture details: `/Users/oeftimie/.claude/plans/mighty-baking-wozniak.md`
