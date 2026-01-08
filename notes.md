# Notes: NOTAM Research

---

# Airspace Closure NOTAM Format Research

## Q-Line Codes for Closures

NOTAM Q codes follow the pattern: **Q** + **Subject (2 letters)** + **Condition (2 letters)**

### Relevant Subject Codes (2nd & 3rd letters):
- **FA**: Aerodrome (general)
- **MR**: Runway (movement area)
- **RA**: Airspace reservation
- **RD**: Danger area
- **RP**: Prohibited area
- **RR**: Restricted area
- **RT**: Temporary restricted area

### Relevant Condition Codes (4th & 5th letters):
- **LC**: Closed
- **LI**: Closed to IFR operations
- **LV**: Closed to VFR operations
- **LN**: Closed to all night operations
- **CA**: Activated
- **CD**: Deactivated

### Common Closure Q-Codes:
| Q-Code | Meaning |
|--------|---------|
| QFALC | Aerodrome closed |
| QMRLC | Runway closed |
| QRTCA | Temporary restricted area activated |
| QRPCA | Prohibited area activated |
| QRRCA | Restricted area activated |
| QAFXX | Airspace general (various) |

## Real-World Closure NOTAM Examples

### 1. Ukrainian Airspace Closure (FIR-Wide)
```
UKBV A0640/22
Q) UKBV/QAFXX/IV/NBO/E/000/999/
E) DUE TO THE MILITARY INVASION OF UKRAINE BY THE RUSSIAN
FEDERATION, THE USE OF AIRSPACE OF UKRAINE WITHIN
UIR KYIV, FIR LVIV, FIR KYIV, FIR DNIPRO, FIR ODESA,
FIR SIMFEROPOL' IS PROHIBITED FOR ALL AIRCRAFT
EXCEPT STATE AIRCRAFT OF UKRAINE OR WITH
THE PERMISSION OF THE GENERAL STAFF OF THE ARMED
FORCES OF UKRAINE.
ATS IS NOT PROVIDED.
```
**Key patterns:** "PROHIBITED FOR ALL AIRCRAFT", "ATS IS NOT PROVIDED"

### 2. Moldova FIR Closure (Ukrainian Crisis)
```
A0046/22 NOTAMR A0045/22
Q) LUUU/QAFXX/IV/BO/E/000/999/4704N02800E098
A) LUUU
E) FIR CHISINAU LUUU CLSD FOR ALL FLIGHTS DUE TO UKRAINIAN CRISIS
WITH FOLLOWING EXCEPTIONS:
A)THE REPOSITIONING FLIGHTS OF CIVIL AIRCRAFT...
```
**Key patterns:** "FIR ... CLSD FOR ALL FLIGHTS", "EXCEPTIONS"

### 3. US FAA Prohibitory NOTAM
```
KICZ A0004/22 SECURITY
THOSE PERSONS DESCRIBED IN PARAGRAPH A (APPLICABILITY) BELOW ARE
PROHIBITED FROM OPERATING AT ALL ALTITUDES IN THE LVIV FLIGHT
INFORMATION REGION (FIR) (UKLV)...
DUE TO SAFETY-OF-FLIGHT RISKS ASSOCIATED WITH ONGOING HOSTILITIES.
SFC—FL999: 24 FEB 19:30 2022 UNTIL PERM
```
**Key patterns:** "PROHIBITED FROM OPERATING", "SAFETY-OF-FLIGHT RISKS", "SFC—FL999"

### 4. Airport Closure
```
Q) KZAU/QMRLC/IV/NBO/A/000/999/4152N08745W005
E) RWY 04L/22R CLSD
```
**Key patterns:** "RWY ... CLSD", "QMRLC" code

## Keywords Indicating Closure/Prohibition

### Critical Keywords (requires immediate pilot attention):
- `CLSD` / `CLOSED`
- `PROHIBITED`
- `NOT PERMITTED`
- `NOT ALLOWED`
- `NO ENTRY`
- `FORBIDDEN`
- `EXCEPT` (indicates exceptions to closure)

### Airspace Type Indicators:
- `FIR` - Flight Information Region
- `UIR` - Upper Information Region
- `CTR` - Control Zone
- `TMA` - Terminal Maneuvering Area
- `PROHIBITED AREA` / `P-XXX`
- `RESTRICTED AREA` / `R-XXXX`
- `DANGER AREA` / `D-XXX`

### Reason Indicators:
- `MILITARY ACTIVITY`
- `MILITARY INVASION`
- `HOSTILITIES`
- `SAFETY-OF-FLIGHT RISKS`
- `SECURITY`
- `EMERGENCY`
- `VOLCANIC ASH`
- `HAZARDOUS`

### ATS Status Indicators:
- `ATS IS NOT PROVIDED`
- `ATS NOT AVAILABLE`
- `NO ATC SERVICES`

## Current App Translator Analysis

The translator already handles:
- ✅ `CLSD` → "Closed"
- ✅ `TFR` → "Temporary flight restriction"
- ✅ `FIR` → "Flight Information Region"
- ✅ `SFC` → "Surface"
- ✅ Summary for "AD CLSD" or "AERODROME CLSD"
- ✅ Summary for "RESTRICTED" or "PROHIBITED"

### Missing/Could Improve:
- ❌ No detection of FIR-wide closures vs airport closures
- ❌ No special handling for "ATS NOT PROVIDED" (critical info)
- ❌ No visual warning indicator for critical closures
- ❌ `PROHIBITED` not in abbreviations (but detected in summary)

## Recommendations

1. **Add severity indicator** for critical NOTAMs:
   - Red badge for "PROHIBITED", "CLSD" at FIR level, "NO ATS"
   - Orange for airport closures
   - Yellow for restricted areas

2. **Enhance summary generation** to detect:
   - FIR-wide closures: "Airspace closed: [FIR names]"
   - No ATS: append "- No ATC services"
   - Military/security: indicate reason

3. **Add abbreviations**:
   - `ATS` → "Air Traffic Services"
   - `UIR` → "Upper Information Region"
   - `PROHIBITED` → keep as-is (clear)

---

# Eurocontrol NOTAM API Research

## Sources

### Source 1: Eurocontrol EAD (European AIS Database)
- URL: https://www.eurocontrol.int/service/european-ais-database
- Key points:
  - World's largest aeronautical information management (AIM) system
  - Covers ECAC and ECAC+ areas (European Civil Aviation Conference)
  - Three access tiers:
    1. **EAD Basic** (Free): Limited data for general public, NOT for operational use
    2. **EAD Pro** (Paid): Software license required, full feature desktop client
    3. **MyEAD/AIMSL** (B2B API): System-to-system web services, requires Data User Agreement

### Source 2: Eurocontrol NM B2B Web Services
- URL: https://www.eurocontrol.int/service/network-manager-business-business-b2b-web-services
- Key points:
  - Network Manager business-to-business interface
  - Requires PKI certificate authentication
  - Registration via NM.servicerequests@eurocontrol.int
  - Invoices payable within 30 days
  - Accounts not used for 6 months may be cancelled
  - Primarily for FMPs (Flow Management Positions) and ANI airports

### Source 3: SWIM Registry Services
- URL: https://eur-registry.swim.aero
- Key points:
  - SADIS OPMET API includes NOTAMs (Met Office UK)
  - NOTAM Geospatial Service (ENAIRE Spain) - REST/GeoJSON
  - Aeronautical Feature On Demand (AFOD) - requires AIMSL license

### Source 4: FAA API Portal
- URL: https://api.faa.gov
- Key points:
  - Official FAA API portal with multiple endpoints
  - Requires registration and approval (few days wait)
  - Limit: 30 requests per minute, single location at a time
  - International NOTAM coverage available

### Source 5: Commercial Alternatives
- Cirium/Laminar Data (developer.laminardata.aero): Comprehensive NOTAM API, credit-based
- Boeing/Jeppesen: Enterprise NOTAM solution with analyst curation
- Notamify: Archive and active NOTAMs, credit-based pricing
- Aviationstack: General aviation data, commercial pricing

## Synthesized Findings

### Current FAA API Coverage Assessment
Our current implementation uses `https://notams.aim.faa.gov/notamSearch/search`:
- **Already provides international NOTAMs** including European airports
- Working for: LROP (Bucharest), EGLL (London Heathrow), etc.
- Data sourced from ICAO international NOTAM exchange
- No registration or authentication required
- No apparent rate limiting issues

### Eurocontrol Access Requirements

| Tier | Cost | Authentication | Use Case |
|------|------|----------------|----------|
| EAD Basic | Free | Simple registration | Non-operational viewing only |
| EAD Pro | License fee | Software + credentials | Desktop operational use |
| MyEAD (B2B) | Agreement + possible fees | AIMSL Certificate | System integration |
| NM B2B | Certificate + fees | PKI certificates | Enterprise integration |

### Key Barriers to Eurocontrol Integration
1. **Complex Registration**: Multi-step process requiring organizational agreements
2. **Certificate-Based Auth**: PKI certificates with 3-year validity
3. **Costs**: Potential service and royalty charges for B2B access
4. **Not for Personal Apps**: B2B services designed for aviation operators, not consumer apps
5. **Data Overlap**: FAA already provides European NOTAMs via ICAO exchange

### Data Format Comparison
| Source | Format | Auth | Coverage |
|--------|--------|------|----------|
| FAA NOTAM Search | JSON | None | Worldwide (via ICAO) |
| EAD/MyEAD | XML (AIXM) | Certificate | ECAC + ECAC+ |
| NM B2B | SOAP/XML | PKI | European ATM network |
| api.faa.gov | JSON | API Key | US + International |

## Recommendation

**Do NOT pursue Eurocontrol integration for this app.**

Reasons:
1. FAA API already provides adequate European NOTAM coverage
2. Eurocontrol B2B is designed for aviation organizations, not personal apps
3. Complex registration and potential costs are not justified
4. Certificate management adds operational complexity

**Alternative improvements to consider:**
1. Use official `api.faa.gov` NOTAM endpoint (requires registration, better documented)
2. Add local caching to reduce API calls
3. Implement better FIR detection for European airports
4. Consider commercial API if higher reliability needed (Cirium, Notamify)
