# Context Summary

## Active Context
- Currently working on: Project initialized, ready for F001 (Xcode project creation)
- Blocking issues: None
- Next up: F001-F003 setup features, then F004-F006 data models

## Cross-Cutting Concerns
- **iOS Version**: iOS 17+ minimum (enables NavigationStack, modern SwiftUI)
- **No Third-Party Dependencies**: Pure Apple native stack
- **Background Execution**: Must respect iOS background limits (30 seconds typical)
- **Network**: Must handle offline gracefully, show cached data
- **Accessibility**: VoiceOver and Dynamic Type support required

## Domain: NOTAM Data

### Decisions
- Use FAA NOTAM API at notams.aim.faa.gov (2026-01-07)
- Default FIR is LROP (Bucharest, Romania) per user requirement (2026-01-07)
- Store raw NOTAM text alongside parsed data for fidelity (2026-01-07)

### Patterns
- NOTAM ID format: series + number (e.g., "M0483/23")
- ICAO location codes: 4 uppercase letters (e.g., LROP, KJFK)
- Q-code: Encodes category/scope/traffic in standardized format

### Gotchas
- NOTAM text uses aviation abbreviations heavily - need translation dictionary
- Effective dates can be "PERM" (permanent) - handle as special case
- Some NOTAMs have estimated end times (EST) - display appropriately

## Domain: Background Refresh

### Decisions
- Use BGTaskScheduler (not deprecated background fetch) (2026-01-07)
- Register task identifier: "com.notamapp.refresh" (2026-01-07)
- Default refresh interval: 6 hours (2026-01-07)

### Patterns
- Always schedule next task at end of current task
- Cache results even on partial failure
- Compare before notifying to avoid duplicates

### Gotchas
- iOS may delay/skip background tasks based on system conditions
- Must complete work within ~30 seconds or risk termination
- Battery optimization can prevent tasks on low battery

## Domain: Notifications

### Decisions
- Use UNUserNotificationCenter for local notifications (2026-01-07)
- Group notifications by FIR (2026-01-07)

### Patterns
- Request permission on first app launch
- Deep link to specific NOTAM from notification

### Gotchas
- Permission can be revoked in Settings - check each time
- Notification content limited to ~4 lines visible

## Domain: UI/UX

### Decisions
- Tab-based navigation (NOTAMs, Changes, Settings) (2026-01-07)
- Segmented control in detail view for Original/Translated (2026-01-07)
- Pull-to-refresh for manual update (2026-01-07)

### Patterns
- Use SF Symbols for consistency
- Semantic colors for dark mode support
- Form style for settings

### Gotchas
- NOTAM text can be very long - ensure scrollable
- Original NOTAM should use monospace for alignment

## Closed Work Streams
<!-- None yet -->
