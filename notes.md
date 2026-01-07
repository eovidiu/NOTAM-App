# Notes: Eurocontrol NOTAM API Research

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
