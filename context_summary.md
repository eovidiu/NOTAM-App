# Context Summary

## Active Context
- Currently working on: Project complete, ready for testing
- Blocking issues: None
- Next up: Open in Xcode, build, test API connectivity

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
- API uses POST with form data, not GET with query params (2026-01-07)

### Patterns
- NOTAM ID format: series + number (e.g., "M0483/23")
- ICAO location codes: 4 uppercase letters (e.g., LROP, KJFK)
- Q-code: Encodes category/scope/traffic in standardized format
- Actor pattern for thread-safe service classes

### Gotchas
- NOTAM text uses aviation abbreviations heavily - translator has 100+ mappings
- Effective dates can be "PERM" (permanent) - handled as special case
- Some NOTAMs have estimated end times (EST) - displayed appropriately
- FAA API response structure may vary - multiple parsing strategies implemented

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
- Deep link to specific change from notification (2026-01-07)

### Patterns
- Request permission on first app launch
- Thread identifier groups notifications by FIR
- Clear badge when Changes tab viewed

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
- NavigationStack with value-based navigation

### Gotchas
- NOTAM text can be very long - scrollable views required
- Original NOTAM uses monospace for proper alignment
- Badge on Changes tab shows unread count

## Closed Work Streams
- Full implementation complete (2026-01-07)
  - 42 features implemented
  - 4 models, 9 services, 11 views
  - Unit tests and UI tests included
