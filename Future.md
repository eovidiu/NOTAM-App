# Aviation API Integration & Feature Proposals

## Executive Summary

Research completed on free aviation APIs available in 2025-2026. This plan proposes new features for the NOTAM app that would be visually appealing and add value to end users, leveraging free API data.

**Current State:** The app displays NOTAMs with a premium "Aviation Glass" UI but has no map visualization, weather data, or live flight tracking.

---

## Free Aviation APIs Researched

| API | Data Type | Free Tier | Best For |
|-----|-----------|-----------|----------|
| **OpenSky Network** | ADS-B flight tracking | ✅ Unlimited (rate-limited) | Live aircraft positions |
| **AVWX** | METAR, TAF, SIGMET | ✅ Core features free | Aviation weather |
| **CheckWX** | METAR, TAF | ✅ Personal plan | Weather alternative |
| **OpenAIP** | Airspace, TFRs, NAVAIDs | ✅ CC BY-NC 4.0 | Airspace boundaries |
| **ADS-B Exchange** | Unfiltered ADS-B | ✅ RapidAPI tier | Military/blocked aircraft |
| **AviationStack** | Flight status | ⚠️ 100 req/month | Prototyping only |
| **FlightAware AeroAPI** | Professional tracking | ⚠️ 500 req/month | Personal use only |

---

## Feature Proposals (Ranked by Visual Impact)

### 🗺️ PROPOSAL 1: Interactive NOTAM Map (HIGH IMPACT)

**APIs Used:** Apple MapKit + existing NOTAM coordinates

**Visual Appeal:** ⭐⭐⭐⭐⭐

**Description:**
Display NOTAMs on an interactive map with color-coded pins/polygons by severity.

**Features:**
- Map view tab showing all active NOTAMs geographically
- Severity-colored pins: 🔴 Critical, 🟠 Warning, 🟡 Caution, 🟢 Info
- Circular overlays for NOTAMs with radius (already have coordinates + radius in model)
- Tap pin → show NOTAM card overlay
- Cluster pins when zoomed out
- Filter by FIR region
- "Fly to my location" button

**Technical Notes:**
- Uses existing `Coordinates` model (latitude, longitude, radius)
- MapKit is free (no API costs)
- ~65% of NOTAMs have coordinate data

**Effort:** Medium (2-3 days)

---

### ✈️ PROPOSAL 2: Live Flight Overlay on Map (HIGH IMPACT)

**APIs Used:** OpenSky Network (FREE)

**Visual Appeal:** ⭐⭐⭐⭐⭐

**Description:**
Show real-time aircraft positions on the NOTAM map, making it visually dynamic.

**Features:**
- Aircraft icons moving in real-time (updates every 10 seconds)
- Tap aircraft → show callsign, altitude, speed, origin/destination
- Color-code aircraft by altitude (low/medium/high)
- Visual correlation: see aircraft approaching NOTAM areas
- Toggle aircraft layer on/off

**Technical Notes:**
- OpenSky: 1 request per 10 seconds (unauthenticated), global coverage
- Endpoint: `GET /states/all?lamin=&lomin=&lamax=&lomax=` (bounding box)
- Returns: icao24, callsign, origin_country, longitude, latitude, altitude, velocity, heading

**Effort:** Medium (2-3 days)

---

### 🌤️ PROPOSAL 3: Aviation Weather Widget (MEDIUM IMPACT)

**APIs Used:** AVWX or CheckWX (FREE)

**Visual Appeal:** ⭐⭐⭐⭐

**Description:**
Show current METAR/TAF weather for configured airports alongside NOTAMs.

**Features:**
- Weather section on NOTAM detail view (for that airport)
- Decoded weather: Wind, visibility, clouds, temperature, pressure
- Flight category badge: VFR 🟢 / MVFR 🔵 / IFR 🔴 / LIFR 🟣
- TAF forecast timeline (next 24 hours)
- Weather warnings (SIGMET/AIRMET) as special NOTAM-like cards

**Visual Concept:**
```
┌─────────────────────────────────┐
│ 🌤️ LROP Weather                │
│ VFR ● 10SM ● 28°C               │
│ Wind: 270° @ 12kt               │
│ Clouds: SCT045 BKN080           │
│ ─────────────────────────────── │
│ TAF: VFR → MVFR (18:00Z)        │
└─────────────────────────────────┘
```

**Technical Notes:**
- AVWX: Free API key, returns parsed METAR/TAF
- Endpoint: `GET /metar/{icao}` and `GET /taf/{icao}`
- Natural pairing with NOTAM location data

**Effort:** Low-Medium (1-2 days)

---

### 🎯 PROPOSAL 4: Airspace Visualization (MEDIUM IMPACT)

**APIs Used:** OpenAIP (FREE)

**Visual Appeal:** ⭐⭐⭐⭐

**Description:**
Overlay airspace boundaries (CTR, TMA, Restricted, Prohibited) on the map.

**Features:**
- Colored polygon overlays for different airspace classes
- Class A-G airspace with standard colors
- Restricted/Prohibited zones highlighted
- Active TFRs as pulsing red zones
- Toggle airspace layer on/off

**Technical Notes:**
- OpenAIP provides GeoJSON airspace data
- Can download and bundle for offline use
- Updates available via streaming API

**Effort:** Medium (2-3 days)

---

### 📊 PROPOSAL 5: NOTAM Statistics Dashboard (LOW IMPACT)

**APIs Used:** None (derived from existing data)

**Visual Appeal:** ⭐⭐⭐

**Description:**
Animated charts showing NOTAM trends and statistics.

**Features:**
- Donut chart: NOTAMs by severity
- Bar chart: NOTAMs per FIR
- Timeline: NOTAM activity over past 7 days
- "Most affected airports" ranking
- Changes trend (new vs expired per day)

**Visual Concept:**
```
┌─────────────────────────────────┐
│ 📊 NOTAM Overview               │
│ ┌──────┐                        │
│ │  🔴12 │ Critical: 12          │
│ │ 🟠38  │ Warning: 38           │
│ └──────┘ Caution: 89 Info: 156  │
│                                 │
│ Top Affected: LROP (45), KJFK   │
└─────────────────────────────────┘
```

**Technical Notes:**
- Uses Swift Charts (iOS 16+)
- Data already available in AppState
- No API calls needed

**Effort:** Low (1 day)

---

### 🔔 PROPOSAL 6: Smart Geofence Alerts (MEDIUM IMPACT)

**APIs Used:** CoreLocation + existing NOTAM coordinates

**Visual Appeal:** ⭐⭐⭐

**Description:**
Alert users when they enter/approach an active NOTAM area.

**Features:**
- Background location monitoring (if permitted)
- Push notification when within 5nm of critical NOTAM
- "NOTAMs near me" quick filter
- Distance indicator on NOTAM cards

**Technical Notes:**
- Uses `CLCircularRegion` for geofencing
- iOS limits to 20 simultaneous geofences
- Prioritize critical/warning NOTAMs

**Effort:** Medium (2 days)

---

## Recommended Implementation Order

| Priority | Feature | Visual Impact | Effort | APIs |
|----------|---------|---------------|--------|------|
| 1️⃣ | Interactive NOTAM Map | ⭐⭐⭐⭐⭐ | Medium | MapKit (free) |
| 2️⃣ | Aviation Weather Widget | ⭐⭐⭐⭐ | Low | AVWX (free) |
| 3️⃣ | Live Flight Overlay | ⭐⭐⭐⭐⭐ | Medium | OpenSky (free) |
| 4️⃣ | Airspace Visualization | ⭐⭐⭐⭐ | Medium | OpenAIP (free) |
| 5️⃣ | Statistics Dashboard | ⭐⭐⭐ | Low | None |
| 6️⃣ | Geofence Alerts | ⭐⭐⭐ | Medium | CoreLocation |

**Rationale:** Map first (biggest visual upgrade), then weather (natural pairing), then live flights (wow factor).

---

## API Integration Architecture

```
┌─────────────────────────────────────────────┐
│                 AppState                     │
├─────────────────────────────────────────────┤
│  NOTAMService    │  WeatherService (new)    │
│  (FAA API)       │  (AVWX/CheckWX)          │
├──────────────────┼──────────────────────────┤
│  FlightService   │  AirspaceService (new)   │
│  (OpenSky)       │  (OpenAIP)               │
└─────────────────────────────────────────────┘
```

All new services follow existing actor pattern with:
- Retry logic with exponential backoff
- Caching layer
- Error handling
- Rate limit awareness
