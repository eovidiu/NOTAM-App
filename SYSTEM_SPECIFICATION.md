# NOTAM App - System Specification

**Version:** 1.0.0
**Platform:** iOS 17.0+
**Last Updated:** 2026-01-12

---

## 1. Context & Boundaries

### 1.1 Purpose

NOTAM App delivers real-time Notice to Air Missions (NOTAMs) to iOS devices. It enables users to:
- Monitor multiple Flight Information Regions (FIRs) simultaneously
- Receive push notifications for airspace changes
- Translate aviation abbreviations to plain English
- Track changes to NOTAMs over time

### 1.2 Target Users

- **Primary:** Drone operators, aviation enthusiasts, researchers
- **Secondary:** Pilots (supplementary use - NOT for operational decisions)
- **Note:** No aviation background required

### 1.3 Stakeholders

| Stakeholder | Interest |
|-------------|----------|
| End Users | Real-time airspace information, easy-to-understand NOTAMs |
| App Owner (Ovidiu) | Functional, maintainable codebase |
| FAA | Proper use of public NOTAM data |

### 1.4 External Dependencies

| Dependency | Purpose | Criticality |
|------------|---------|-------------|
| FAA NOTAM Search API | Source of NOTAM data | Critical |
| Apple Push Notification Service | Local notifications | High |
| iOS Background Tasks | Background refresh | Medium |
| CoreLocation | Location-based FIR discovery | Low |

### 1.5 Constraints

- **No third-party dependencies** - Pure Apple native stack
- **iOS 17+ minimum** - Enables NavigationStack, modern SwiftUI
- **iPhone only** - No iPad support (as of v1.0)
- **Dark mode only** - Forced dark color scheme

---

## 2. Domain Model

### 2.1 Core Entities

```
┌─────────────────┐      ┌──────────────────┐
│     NOTAM       │──────│   NOTAMChange    │
├─────────────────┤      ├──────────────────┤
│ id: String      │      │ id: UUID         │
│ series: String  │      │ changeType       │
│ number: String  │      │ notam: NOTAM     │
│ type: NOTAMType │      │ previousNotam?   │
│ issued: Date    │      │ detectedAt: Date │
│ affectedFIR     │      │ isRead: Bool     │
│ text: String    │      └──────────────────┘
│ severity        │
│ effectiveStart  │      ┌──────────────────┐
│ effectiveEnd?   │      │       FIR        │
│ isPermanent     │      ├──────────────────┤
│ coordinates?    │      │ id: UUID         │
└─────────────────┘      │ icaoCode: String │
                         │ displayName      │
                         │ isEnabled: Bool  │
                         └──────────────────┘
```

### 2.2 Enumerations

**NOTAMSeverity** (4 levels):
| Level | Priority | Color | Use Case |
|-------|----------|-------|----------|
| critical | 0 | Red | FIR/airspace prohibited, no ATS |
| warning | 1 | Orange | Airport/runway closed, restricted areas |
| caution | 2 | Yellow | TFR, partial closures |
| info | 3 | Green | Normal NOTAMs |

**NOTAMType**:
- `new` (N) - New NOTAM
- `replacement` (R) - Replaces existing
- `cancellation` (C) - Cancels existing

**ChangeType**:
- `new` - NOTAM added
- `expired` - NOTAM no longer in feed
- `modified` - Content changed
- `cancelled` - Explicit cancellation

**RefreshInterval**:
- `oneHour` - 1 hour
- `sixHours` - 6 hours (default)
- `twelveHours` - 12 hours

### 2.3 Invariants

1. ICAO codes MUST be exactly 4 uppercase letters (`^[A-Z]{4}$`)
2. Every NOTAM MUST have an `id`, `text`, and `effectiveStart`
3. If `isPermanent` is true, `effectiveEnd` MUST be nil
4. Severity is derived from text content, not stored separately
5. Changes MUST reference a valid NOTAM

---

## 3. Functional Requirements

### 3.1 NOTAM Viewing

**FR-001: Display NOTAMs by FIR**
- Given: User has configured FIRs
- When: App launches or refreshes
- Then: NOTAMs are grouped by FIR and sorted by effectiveStart (newest first)

**FR-002: Filter Active NOTAMs**
- Given: NOTAM list is displayed
- When: User selects "Active Only" filter
- Then: Only NOTAMs where `isActive == true` are shown

**FR-003: Search NOTAMs**
- Given: NOTAM list is displayed
- When: User enters search text
- Then: NOTAMs are filtered by text, displayId, or location

**FR-004: View NOTAM Detail**
- Given: User taps a NOTAM row
- When: Detail view opens
- Then: Full NOTAM text, translated version, and metadata are shown

**FR-005: Translate NOTAM Text**
- Given: NOTAM detail is displayed
- When: User views "Translated" tab
- Then: Aviation abbreviations are expanded to plain English (100+ mappings)

### 3.2 FIR Management

**FR-010: Add FIR Manually**
- Given: User is on Settings
- When: User taps "Add FIR" and enters valid ICAO code
- Then: FIR is added to configured list

**FR-011: Add FIR by Location**
- Given: User grants location permission
- When: User taps "Near Me"
- Then: FIRs within 500km radius are shown, sorted by distance

**FR-012: Toggle FIR Enabled**
- Given: FIR is in configured list
- When: User taps the FIR row
- Then: FIR's isEnabled state toggles (affects fetching)

**FR-013: Remove FIR**
- Given: FIR is in configured list
- When: User swipes to delete
- Then: FIR is removed from configuration

### 3.3 Change Tracking

**FR-020: Detect NOTAM Changes**
- Given: Background refresh completes
- When: New data differs from cached data
- Then: Changes (new, expired, modified, cancelled) are recorded

**FR-021: Display Changes**
- Given: Changes have been detected
- When: User views Changes tab
- Then: Changes are listed with type indicators and timestamps

**FR-022: Mark Changes as Read**
- Given: User views a change
- When: User navigates to detail
- Then: Change is marked as read

**FR-023: Badge Unread Count**
- Given: Unread changes exist
- When: App is in foreground
- Then: Changes tab shows badge with unread count

### 3.4 Notifications

**FR-030: Request Permission**
- Given: First app launch
- When: User has not responded to notification prompt
- Then: System permission dialog is shown

**FR-031: Notify Critical Airspace**
- Given: Notification permission granted AND severity meets threshold
- When: New NOTAM meets threshold (critical by default)
- Then: Time-sensitive push notification is sent

**FR-032: Notify of Changes**
- Given: Background refresh detects changes
- When: Notifications are enabled
- Then: Grouped notification per FIR is sent

**FR-033: Deep Link from Notification**
- Given: User taps notification
- When: App opens
- Then: App navigates to relevant NOTAM/Change

### 3.5 Background Refresh

**FR-040: Schedule Background Refresh**
- Given: App enters background
- When: Refresh interval has passed
- Then: BGAppRefreshTask is scheduled

**FR-041: Execute Background Refresh**
- Given: iOS triggers background task
- When: Task executes
- Then: NOTAMs are fetched, cached, and changes detected

---

## 4. Non-Functional Requirements

### 4.1 Performance

| Metric | Target | Measurement |
|--------|--------|-------------|
| App Launch | < 2s to interactive | Cold start time |
| API Response | < 10s timeout | Network request |
| List Scroll | 60 FPS | Animation smoothness |
| Background Task | < 30s completion | iOS limit |

### 4.2 Reliability

| Aspect | Requirement |
|--------|-------------|
| Offline Mode | Cache MUST be available when network fails |
| Cache Staleness | Entries older than 24h are marked stale |
| API Retry | 3 retries with exponential backoff (1s, 2s, 4s) |
| Data Persistence | Settings survive app reinstall (UserDefaults) |

### 4.3 Security

- No authentication required (public FAA data)
- No PII collected or stored
- No analytics or tracking
- HTTPS only for API communication

### 4.4 Accessibility

| Feature | Implementation |
|---------|----------------|
| VoiceOver | Full support required |
| Dynamic Type | Font scaling supported |
| Reduce Motion | Animations disabled when enabled |
| Color Contrast | 4.5:1 minimum ratio |

---

## 5. Architecture

### 5.1 Layer Diagram

```
┌─────────────────────────────────────────┐
│                  UI Layer               │
│  (SwiftUI Views, Components, Theme)     │
├─────────────────────────────────────────┤
│              State Layer                │
│  (AppState, SettingsStore, ChangeStore) │
├─────────────────────────────────────────┤
│             Service Layer               │
│  (NOTAMService, Cache, Notifications)   │
├─────────────────────────────────────────┤
│              Data Layer                 │
│  (Models, FileManager, UserDefaults)    │
└─────────────────────────────────────────┘
```

### 5.2 Component Responsibilities

| Component | Responsibility |
|-----------|----------------|
| **AppState** | Main app state, coordinates refresh, holds NOTAMs |
| **SettingsStore** | Persists user preferences, FIR configuration |
| **NOTAMService** | Fetches NOTAMs from FAA API, handles retries |
| **NOTAMCache** | File-based caching of NOTAM data |
| **NOTAMChangeDetector** | Compares snapshots to detect changes |
| **ChangeStore** | Persists detected changes, tracks read state |
| **NotificationManager** | Local notification scheduling |
| **BackgroundRefreshManager** | BGTaskScheduler integration |
| **NOTAMTranslator** | Abbreviation expansion (100+ mappings) |
| **FIRLocationService** | Location-based FIR discovery |
| **LocationManager** | CoreLocation wrapper |

### 5.3 Data Flow

```
User Trigger → AppState.refresh()
                    ↓
            NOTAMService.fetchNOTAMs()
                    ↓
              FAA API (POST)
                    ↓
            Parse Response → [NOTAM]
                    ↓
            NOTAMCache.save()
                    ↓
            NOTAMChangeDetector.detectChanges()
                    ↓
            ChangeStore.addChanges()
                    ↓
            NotificationManager.notifyOfChanges()
```

### 5.4 Concurrency Model

- **NOTAMService**: `actor` (thread-safe API calls)
- **NOTAMCache**: `actor` (thread-safe file I/O)
- **AppState**: `@MainActor` (UI-bound state)
- **Background tasks**: Detached `Task` with cancellation support

---

## 6. API Contracts

### 6.1 FAA NOTAM Search API

**Endpoint:** `https://notams.aim.faa.gov/notamSearch/search`

**Method:** POST

**Headers:**
```
Content-Type: application/x-www-form-urlencoded
Accept: application/json
User-Agent: Mozilla/5.0 (Macintosh; ...)
```

**Request Body (form-urlencoded):**
```
searchType=0
designatorsForLocation=LROP
notamType=
flightPathBuffer=10
flightPathIncludeNavaids=true
flightPathIncludeArtcc=false
flightPathIncludeTfr=true
flightPathIncludeRegulatory=false
flightPathResultsType=0
archiveDate=
archiveDesignator=
offset=0
notamsOnly=false
radius=10
```

**Response (JSON):**
```json
{
  "notamList": [
    {
      "notamNumber": "A0172/26",
      "icaoId": "LROP",
      "facilityDesignator": "LROP",
      "startDate": "01/10/2026 0800",
      "endDate": "01/15/2026 1800",
      "issueDate": "01/09/2026 1200",
      "traditionalMessage": "RWY 08R/26L CLSD...",
      "icaoMessage": "...",
      "mapPointer": "POINT(-73.7789 40.6398)"
    }
  ],
  "error": null
}
```

**Error Codes:**
| HTTP Code | Meaning | Retry? |
|-----------|---------|--------|
| 200 | Success | N/A |
| 400-499 | Client error | No |
| 429 | Rate limited | Yes (backoff) |
| 500-599 | Server error | Yes |

### 6.2 Internal Data Persistence

**Settings (UserDefaults):**
```
Key: "appSettings"
Value: JSON-encoded AppSettings struct
```

**Cache (FileManager):**
```
Location: <CachesDirectory>/NOTAMCache/
Files: {ICAO_CODE}.json
Format: CacheEntry { notams: [NOTAM], timestamp: Date }
```

**Changes (FileManager):**
```
Location: <ApplicationSupport>/changes.json
Format: [NOTAMChange]
```

---

## 7. Data Ownership

| Data | Source of Truth | Retention |
|------|-----------------|-----------|
| NOTAMs | FAA API (fetched) | 24h cache, then refreshed |
| FIR Config | User (UserDefaults) | Permanent |
| Settings | User (UserDefaults) | Permanent |
| Changes | Computed (from diffs) | 7 days |
| Notified IDs | Local (UserDefaults) | 7 days |

---

## 8. State Machines

### 8.1 App Loading State

```
       ┌──────────┐
       │  Idle    │
       └────┬─────┘
            │ refresh()
            ▼
       ┌──────────┐
       │ Loading  │
       └────┬─────┘
            │
    ┌───────┴───────┐
    │               │
    ▼               ▼
┌──────────┐  ┌──────────┐
│ Success  │  │  Error   │
└──────────┘  └────┬─────┘
                   │ retry
                   └──────→ Loading
```

### 8.2 Notification Authorization

```
┌────────────────┐
│ Not Determined │
└───────┬────────┘
        │ requestAuthorization()
        ▼
   ┌────┴────┐
   │         │
   ▼         ▼
┌──────┐  ┌──────┐
│Granted│  │Denied│
└──────┘  └──────┘
             │
             │ openSettings()
             ▼
         ┌──────┐
         │Granted│
         └──────┘
```

---

## 9. Security Considerations

### 9.1 Data Handling
- All NOTAM data is publicly available (no secrets)
- No user authentication required
- No PII collected or transmitted

### 9.2 Network Security
- HTTPS enforced for all API calls
- Certificate pinning: Not implemented (public API)
- Request timeout: 30 seconds

### 9.3 Local Storage
- Cache stored in Caches directory (may be purged by iOS)
- Settings stored in UserDefaults (backed up to iCloud)
- No sensitive data stored

---

## 10. Operations

### 10.1 Observability

**Logging:**
- `os.log` with subsystem `com.notamapp.NOTAMApp`
- Categories: `NOTAMService`, `AppState`

**No Analytics:** No crash reporting or usage analytics

### 10.2 Error Handling

| Error Type | User Feedback | Recovery |
|------------|---------------|----------|
| Network unavailable | ErrorView with retry | Manual refresh |
| API timeout | ErrorView with retry | Manual refresh |
| Parse failure | Silent, use cache | Automatic |
| Cache miss | Empty state | Manual refresh |

### 10.3 Background Task Monitoring

- Task ID: `com.notamapp.refresh`
- Scheduled via BGTaskScheduler
- Completion logged to console
- Next refresh shown in Settings UI

---

## 11. Testing Strategy

### 11.1 Unit Tests

| Test File | Coverage |
|-----------|----------|
| `NOTAMTests.swift` | Model parsing, severity calculation |
| `NOTAMChangeDetectorTests.swift` | Change detection logic |
| `NOTAMTranslatorTests.swift` | Abbreviation expansion |

### 11.2 UI Tests

| Test File | Coverage |
|-----------|----------|
| `NOTAMAppUITests.swift` | Navigation, AddFIR flow |

### 11.3 Manual Testing

- VoiceOver walkthrough
- Dynamic Type scaling
- Background refresh simulation
- Network failure handling

---

## 12. Architectural Decisions

### ADR-001: Pure Swift/SwiftUI Stack

**Status:** Accepted

**Context:** Need to decide on UI framework and dependencies.

**Decision:** Use pure Apple stack (SwiftUI, Combine, async/await) with no third-party dependencies.

**Rationale:**
- Reduces maintenance burden
- No dependency conflicts
- Better long-term stability
- Smaller app size

**Consequences:**
- May need to implement features that libraries provide
- Limited to Apple platform evolution

---

### ADR-002: Actor-Based Services

**Status:** Accepted

**Context:** Services need thread-safe access to shared state.

**Decision:** Use Swift `actor` for NOTAMService and NOTAMCache.

**Rationale:**
- Native Swift concurrency
- Automatic thread safety
- No manual locking required
- Works well with async/await

**Consequences:**
- All service calls must be async
- Requires Swift 5.5+

---

### ADR-003: FAA API for NOTAM Data

**Status:** Accepted

**Context:** Need reliable NOTAM data source.

**Decision:** Use FAA NOTAM Search API at `notams.aim.faa.gov`.

**Rationale:**
- Publicly available (no auth required)
- Covers international NOTAMs
- Well-documented format

**Consequences:**
- Dependent on FAA service availability
- Rate limiting may apply
- API format may change without notice

---

### ADR-004: File-Based Caching

**Status:** Accepted

**Context:** Need offline support for NOTAM data.

**Decision:** Use FileManager with JSON files in Caches directory.

**Rationale:**
- Simple implementation
- No database overhead
- iOS manages cache purging
- Easy debugging (readable files)

**Consequences:**
- Not suitable for large datasets
- No query capabilities
- Per-FIR file granularity

---

### ADR-005: BGTaskScheduler for Background Refresh

**Status:** Accepted

**Context:** Need periodic data refresh when app is backgrounded.

**Decision:** Use BGAppRefreshTask via BGTaskScheduler.

**Rationale:**
- Apple-recommended approach
- Respects system resources
- Battery-efficient

**Consequences:**
- Execution timing not guaranteed
- 30-second time limit
- Requires background modes entitlement

---

### ADR-006: Dark-First Design System

**Status:** Accepted

**Context:** Need consistent visual design.

**Decision:** Implement "Aviation Glass" design system with forced dark mode.

**Rationale:**
- Aviation industry aesthetic (cockpit displays)
- Reduces eye strain in low-light
- Premium visual appearance

**Consequences:**
- No light mode option
- All colors designed for dark backgrounds
- Accessibility requires careful contrast management

---

### ADR-007: Dictionary-Based Translation

**Status:** Accepted

**Context:** Need to translate aviation abbreviations to plain English.

**Decision:** Use static dictionary of 100+ abbreviations.

**Rationale:**
- Instant, offline translation
- Predictable results
- No API dependency

**Consequences:**
- May miss context-specific meanings
- Manual maintenance of dictionary
- Future AI translation planned (iOS 26+ Foundation Models)

---

### ADR-008: Default FIR is LROP (Bucharest)

**Status:** Accepted

**Context:** App needs a default FIR for first launch.

**Decision:** Default to LROP (Bucharest Henri Coandă International Airport).

**Rationale:**
- User requirement (Ovidiu is in Romania)
- Valid, active airport with NOTAMs

**Consequences:**
- Non-Romanian users must configure their FIRs

---

### ADR-009: iPhone-Only Support

**Status:** Accepted

**Context:** Decide on device support scope.

**Decision:** Support iPhone only, no iPad optimization.

**Rationale:**
- Faster development
- Simpler UI (no split view)
- Mobile-first use case

**Consequences:**
- iPad users get iPhone layout scaled
- No landscape optimization

---

### ADR-010: Severity Threshold for Notifications

**Status:** Accepted

**Context:** Users may receive too many notifications.

**Decision:** Allow users to set minimum severity threshold (Critical only, or Caution+).

**Rationale:**
- Reduces notification fatigue
- Critical-only is sensible default
- User control over noise

**Consequences:**
- Some users may miss non-critical changes
- UI complexity for threshold picker

---

## 13. Traceability Matrix

| Requirement | Implementation | Test |
|-------------|----------------|------|
| FR-001 | NOTAMListView + AppState.notamsByFIR | Manual |
| FR-002 | NOTAMListView.showInactiveNotams | Manual |
| FR-003 | NOTAMListView.filteredNotamsByFIR | Manual |
| FR-004 | NOTAMDetailView | Manual |
| FR-005 | NOTAMTranslator | NOTAMTranslatorTests |
| FR-010 | AddFIRView | NOTAMAppUITests |
| FR-011 | LocateFIRsView + FIRLocationService | Manual |
| FR-020 | NOTAMChangeDetector | NOTAMChangeDetectorTests |
| FR-030 | NotificationManager.requestAuthorization | Manual |
| FR-031 | NotificationManager.sendCriticalAirspaceNotification | Manual |
| FR-040 | BackgroundRefreshManager.scheduleRefresh | Manual |

---

## Appendix A: File Structure

```
NOTAMApp/
├── NOTAMApp.swift              # App entry point
├── ContentView.swift           # Tab container
├── Models/
│   ├── NOTAM.swift             # Core NOTAM model
│   ├── NOTAMChange.swift       # Change tracking model
│   ├── FIR.swift               # FIR configuration
│   ├── AppSettings.swift       # User preferences
│   └── ATSUnit.swift           # ATS unit data
├── Services/
│   ├── NOTAMService.swift      # API client (actor)
│   ├── NOTAMCache.swift        # File cache (actor)
│   ├── NOTAMChangeDetector.swift
│   ├── NOTAMTranslator.swift   # Abbreviation dictionary
│   ├── ChangeStore.swift       # Change persistence
│   ├── SettingsStore.swift     # Settings persistence
│   ├── AppState.swift          # Main state container
│   ├── NotificationManager.swift
│   ├── BackgroundRefreshManager.swift
│   ├── LocationManager.swift
│   ├── FIRLocationService.swift
│   ├── ATSUnitService.swift
│   └── NotifiedNOTAMStore.swift
├── Views/
│   ├── NOTAM/
│   │   ├── NOTAMListView.swift
│   │   ├── NOTAMRowView.swift
│   │   └── NOTAMDetailView.swift
│   ├── Changes/
│   │   ├── ChangesListView.swift
│   │   └── ChangeDetailView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── AddFIRView.swift
│   │   └── LocateFIRsView.swift
│   └── Components/
│       ├── LoadingView.swift
│       ├── ErrorView.swift
│       └── EmptyStateView.swift
├── Components/
│   ├── GlassCard.swift
│   ├── SeverityBadge.swift
│   ├── NOTAMIDBadge.swift
│   ├── FIRCodePill.swift
│   ├── SectionHeader.swift
│   ├── PremiumSearchBar.swift
│   └── TimelineProgressBar.swift
├── Theme/
│   ├── AviationTheme.swift
│   ├── Typography.swift
│   ├── Animation.swift
│   └── HapticManager.swift
└── Resources/
    ├── fir_coordinates.json    # FIR location database
    └── ats_units.json          # ATS unit database
```

---

## Appendix B: Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| DeepSpace | #0A0A0F | Base background |
| Obsidian | #12121A | Primary surface |
| Graphite | #1C1C28 | Elevated cards |
| SlateGlass | #252535 | Interactive elements |
| ElectricCyan | #00D4FF | Primary accent |
| NeonBlue | #4D9FFF | Links, secondary |
| AuroraGreen | #00FF94 | Success, safe |
| AmberAlert | #FFB800 | Warning |
| CrimsonPulse | #FF3366 | Critical, danger |
| CautionYellow | #FFD600 | Caution |
| VioletGlow | #9D4EDD | Special highlights |
| TextPrimary | #FFFFFF | Headlines |
| TextSecondary | #E5E5EA | Primary text |
| TextTertiary | #A1A1AA | Secondary text |
| TextDisabled | #6B6B7A | Disabled |

---

## Appendix C: Abbreviation Dictionary (Sample)

| Abbreviation | Expansion |
|--------------|-----------|
| ABN | Aerodrome beacon |
| AD | Aerodrome |
| ATC | Air Traffic Control |
| CLSD | Closed |
| FIR | Flight Information Region |
| FL | Flight level |
| IFR | Instrument flight rules |
| ILS | Instrument landing system |
| NOTAM | Notice to Air Missions |
| RWY | Runway |
| TFR | Temporary flight restriction |
| TWY | Taxiway |
| VFR | Visual flight rules |
| VOR | VHF omnidirectional range |

*Full dictionary: 100+ entries in NOTAMTranslator.swift*

---

**Document Owner:** Ovidiu Eftimie
**Review Status:** Draft
**Next Review:** On significant feature changes
