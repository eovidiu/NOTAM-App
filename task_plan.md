# Task Plan: Notification Severity Setting & Last Update Display

## Goal
Add user-configurable notification severity threshold and display last refresh timestamp on main page.

## Features
1. **Notification Severity Setting**: Allow user to choose minimum severity for notifications (Caution or Critical)
2. **Last Update Display**: Show date/time of last successful refresh below search field on NOTAMs list

## Parallelization Analysis

**Can run in parallel:**
- Track 1: Notification severity setting (Settings UI + persistence)
- Track 2: Last update timestamp display (UI + persistence)

**Sequential dependency:**
- Both tracks touch different parts of the codebase, can be developed independently
- Final integration testing after both complete

## Phase Breakdown

### Phase 1: Research & Plan
- [ ] Review current AppSettings model
- [ ] Review current SettingsStore
- [ ] Review current SettingsView
- [ ] Review NOTAMListView for last update placement
- [ ] Review NotificationManager for severity filtering

### Phase 2: Implement Notification Severity Setting
- [ ] Add `notificationSeverityThreshold` to AppSettings
- [ ] Update SettingsStore to persist new setting
- [ ] Add UI picker in SettingsView (Caution/Critical options)
- [ ] Update NotificationManager to respect threshold
- [ ] Update BackgroundRefreshManager notification logic

### Phase 3: Implement Last Update Display
- [ ] Add `lastRefreshDate` to AppSettings or separate store
- [ ] Update refresh logic to save timestamp
- [ ] Add UI element below search in NOTAMListView
- [ ] Format timestamp appropriately (relative or absolute)

### Phase 4: Test & Verify
- [ ] Test notification setting changes take effect
- [ ] Test last update displays correctly after refresh
- [ ] Verify persistence across app restarts

## Status
**Starting Phase 1** - Research current implementation
