# Task Plan: Critical Airspace Closure Notifications

## Goal
Send a push notification when a new Critical severity NOTAM (airspace closure) appears for a monitored FIR, ensuring each NOTAM only triggers one notification.

## Requirements
- Trigger: Critical severity NOTAMs only (FIR/airspace prohibited, no ATS)
- One-time: Track notified NOTAMs to prevent duplicates
- Freshness: Only notify if NOTAM issued within last 3 days
- Timing: Check during background refresh
- Settings: Use existing "Notifications Enabled" toggle

## Phases
- [x] Phase 1: Create NotifiedNOTAMStore to track sent notifications
- [x] Phase 2: Add critical NOTAM detection to background refresh flow
- [x] Phase 3: Implement notification sending logic with deduplication
- [x] Phase 4: Update NotificationManager with critical alert content
- [x] Phase 5: Remove demo NOTAM from NOTAMListView
- [x] Phase 6: Build and test

## Implementation Details

### NotifiedNOTAMStore
- Persist set of NOTAM IDs that have been notified
- Use UserDefaults with JSON encoding
- Auto-cleanup: remove IDs older than 7 days

### Detection Logic
```swift
func shouldNotify(notam: NOTAM) -> Bool {
    // Must be critical severity
    guard notam.severity == .critical else { return false }

    // Must be issued within last 3 days
    let threeDaysAgo = Date().addingTimeInterval(-3 * 24 * 60 * 60)
    guard notam.issued > threeDaysAgo else { return false }

    // Must not have been notified before
    guard !notifiedStore.hasBeenNotified(notam.id) else { return false }

    return true
}
```

### Notification Content
- Title: "⚠️ Critical: Airspace Closed"
- Body: "[FIR] - [Summary from translator]"
- Category: criticalNotam (for deep linking)

## Status
**COMPLETE** - All phases finished successfully
