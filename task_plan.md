# Task Plan: Implement NOTAM Severity Indicator

## Goal
Add visual severity indicators to NOTAMs so pilots can quickly identify critical closures and restrictions.

## Phases
- [x] Phase 1: Add severity enum to NOTAM model
- [x] Phase 2: Implement severity detection logic
- [x] Phase 3: Update NOTAMRowView with severity badge
- [x] Phase 4: Update NOTAMDetailView with severity indicator
- [x] Phase 5: Add missing abbreviations (ATS, UIR)
- [x] Phase 6: Build and test

## Severity Levels
- **critical** (red): FIR/airspace PROHIBITED, "ATS NOT PROVIDED", complete closures
- **warning** (orange): Airport/runway CLSD, restricted areas active
- **caution** (yellow): Temporary restrictions, partial closures
- **info** (default): Normal NOTAMs

## Detection Rules
```
CRITICAL:
- Contains "PROHIBITED" + ("FIR" OR "UIR" OR "AIRSPACE")
- Contains "ATS IS NOT PROVIDED" OR "ATS NOT AVAILABLE"
- Contains "CLSD" + "ALL FLIGHTS"

WARNING:
- Contains "AD CLSD" OR "AERODROME CLSD"
- Contains "RWY" + "CLSD"
- Contains "RESTRICTED AREA" + "ACT"

CAUTION:
- Contains "TFR"
- Contains "CLSD" (other cases)
- Contains "RESTRICTED"

INFO:
- Default for all other NOTAMs
```

## Status
**COMPLETE** - All phases finished successfully
