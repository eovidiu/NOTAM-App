# Task Plan: Locate FIRs Near Me

## Goal
Add a "Locate FIRs near me" button in Settings that finds nearby airports and their associated FIRs based on user location.

## Feature Requirements
1. Button in Settings under "Add FIR" section
2. Request location permission when tapped
3. Search airports within 50km radius of user location
4. Determine which FIRs those airports belong to
5. Present found FIRs for user to add

## Technical Analysis

### Data Source
- Need airport database with coordinates and FIR associations
- Options:
  a) Use existing ats_units.json (has FIR data but no coordinates)
  b) Create airports.json with ICAO code, name, lat/lon, FIR code
  c) Use OpenFlights or similar public airport database

### Components Needed
1. **LocationManager** - CoreLocation wrapper for requesting/getting location
2. **Airport Model** - Airport with coordinates and FIR association
3. **AirportService** - Load airports, find nearby ones
4. **LocateFIRsView** - UI to show location request and results

## Parallelization Analysis

**Sequential (must happen first):**
- Track 0: Create airport database (JSON with coordinates + FIR codes)

**Parallel Tracks (after Track 0):**
- Track 1: LocationManager service (CoreLocation wrapper)
- Track 2: Airport model and AirportService
- Track 3: LocateFIRsView UI

**Final:**
- Track 4: Integration - wire button in SettingsView

## Phase Breakdown

### Phase 1: Research & Data Preparation
- [x] Check existing ats_units.json structure
- [x] Find/create FIR data with coordinates
- [x] Create fir_coordinates.json resource file (~150 FIRs worldwide)

### Phase 2: Implement Location Services
- [x] Create LocationManager (CoreLocation wrapper)
- [x] Add location permission to Info.plist

### Phase 3: Implement FIR Location Service
- [x] Create FIRCoordinate model
- [x] Create FIRLocationService (load, search nearby within radius)

### Phase 4: Implement UI
- [x] Create LocateFIRsView (location request + results)
- [x] Add button to SettingsView FIR section
- [x] Wire up navigation with sheet presentation

### Phase 5: Build & Verify
- [x] Add new files to Xcode project
- [x] Build succeeded with no errors

## Status
**COMPLETED** - Feature implemented and building successfully
