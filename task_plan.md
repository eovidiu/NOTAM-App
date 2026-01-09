# Task Plan: Collapsible FIR Sections

## Goal
Add collapsible/expandable FIR sections in NOTAMs list with persistence across app restarts.

## Requirements
1. Each FIR section can be collapsed/expanded by tapping the header
2. Collapsed state persists to UserDefaults
3. Show chevron indicator (right/down) in section header
4. Animation for collapse/expand transition

## Implementation Plan

### Phase 1: Add Collapse State Management
- [x] Add `@AppStorage` or UserDefaults-backed Set<String> for collapsed FIRs
- [x] Default: all FIRs expanded

### Phase 2: Update NOTAMListView
- [x] Make section header tappable
- [x] Add chevron indicator
- [x] Conditionally show NOTAMs based on collapsed state
- [x] Add animation

### Phase 3: Build & Test
- [ ] Verify build succeeds
- [ ] Test collapse/expand works
- [ ] Test persistence across app restarts

## Status
**In Progress** - Implementing feature
