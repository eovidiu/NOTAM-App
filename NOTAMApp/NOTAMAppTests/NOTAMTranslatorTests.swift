import XCTest
@testable import NOTAMApp

final class NOTAMTranslatorTests: XCTestCase {
    let translator = NOTAMTranslator.shared

    // MARK: - Summary Generation Tests

    func testRunwayClosureSummary() {
        let notam = createTestNOTAM(text: "RWY 08R/26L CLSD DUE TO MAINT")
        let translated = translator.translate(notam)

        XCTAssertTrue(translated.summary.contains("Runway closure"))
        XCTAssertTrue(translated.summary.contains("LROP"))
    }

    func testTaxiwayClosureSummary() {
        let notam = createTestNOTAM(text: "TWY A CLSD BTN TWY B AND TWY C")
        let translated = translator.translate(notam)

        XCTAssertTrue(translated.summary.contains("Taxiway closure"))
    }

    func testAirportClosedSummary() {
        let notam = createTestNOTAM(text: "AD CLSD DUE TO SPECIAL EVENT")
        let translated = translator.translate(notam)

        XCTAssertTrue(translated.summary.contains("Airport closed"))
    }

    func testNavigationAidSummary() {
        let notam = createTestNOTAM(text: "VOR LRP U/S DUE TO MAINT")
        let translated = translator.translate(notam)

        XCTAssertTrue(translated.summary.contains("Navigation aid"))
    }

    func testObstructionSummary() {
        let notam = createTestNOTAM(text: "OBST CRANE ERECTED 500FT AGL")
        let translated = translator.translate(notam)

        XCTAssertTrue(translated.summary.contains("Obstruction"))
    }

    func testAirspaceRestrictionSummary() {
        let notam = createTestNOTAM(text: "TFR IN EFFECT DUE TO VIP MOVEMENT")
        let translated = translator.translate(notam)

        XCTAssertTrue(translated.summary.contains("Airspace restriction"))
    }

    // MARK: - Abbreviation Translation Tests

    func testCommonAbbreviationTranslation() {
        let notam = createTestNOTAM(text: "RWY CLSD DUE TO MAINT WIP")
        let translated = translator.translate(notam)

        XCTAssertTrue(translated.plainText.contains("Runway"))
        XCTAssertTrue(translated.plainText.contains("Closed"))
        XCTAssertTrue(translated.plainText.contains("Maintenance"))
        XCTAssertTrue(translated.plainText.contains("Work in progress"))
    }

    func testNavigationAbbreviations() {
        let notam = createTestNOTAM(text: "VOR/DME U/S TIL FURTHER NOTICE")
        let translated = translator.translate(notam)

        XCTAssertTrue(translated.plainText.contains("VHF omnidirectional range"))
        XCTAssertTrue(translated.plainText.contains("Distance measuring equipment"))
        XCTAssertTrue(translated.plainText.contains("Until"))
    }

    func testTimeAbbreviations() {
        let notam = createTestNOTAM(text: "CLSD MON-FRI 0800-1700")
        let translated = translator.translate(notam)

        XCTAssertTrue(translated.plainText.contains("Monday"))
        XCTAssertTrue(translated.plainText.contains("Friday"))
    }

    // MARK: - Section Generation Tests

    func testSectionGeneration() {
        let notam = createTestNOTAM(
            location: "LROP",
            minimumFL: "000",
            maximumFL: "050",
            scope: "AE"
        )
        let translated = translator.translate(notam)

        let sectionTitles = translated.sections.map { $0.title }

        XCTAssertTrue(sectionTitles.contains("Type"))
        XCTAssertTrue(sectionTitles.contains("Location"))
        XCTAssertTrue(sectionTitles.contains("Effective Period"))
        XCTAssertTrue(sectionTitles.contains("Altitude"))
        XCTAssertTrue(sectionTitles.contains("Scope"))
    }

    func testAltitudeFormatting() {
        // Surface to 5000ft
        let lowAltNotam = createTestNOTAM(minimumFL: "000", maximumFL: "050")
        let lowTranslated = translator.translate(lowAltNotam)

        let altSection = lowTranslated.sections.first { $0.title == "Altitude" }
        XCTAssertNotNil(altSection)
        XCTAssertTrue(altSection!.content.contains("surface"))

        // All altitudes
        let allAltNotam = createTestNOTAM(minimumFL: "000", maximumFL: "999")
        let allTranslated = translator.translate(allAltNotam)

        let allAltSection = allTranslated.sections.first { $0.title == "Altitude" }
        XCTAssertNotNil(allAltSection)
        XCTAssertTrue(allAltSection!.content.contains("unlimited"))
    }

    func testScopeTranslation() {
        let notam = createTestNOTAM(scope: "AEW")
        let translated = translator.translate(notam)

        let scopeSection = translated.sections.first { $0.title == "Scope" }
        XCTAssertNotNil(scopeSection)
        XCTAssertTrue(scopeSection!.content.contains("Aerodrome"))
        XCTAssertTrue(scopeSection!.content.contains("En-route"))
        XCTAssertTrue(scopeSection!.content.contains("Navigation warning"))
    }

    // MARK: - Coordinate Tests

    func testCoordinateFormatting() {
        let notam = createTestNOTAM(
            coordinates: Coordinates(latitude: 44.5, longitude: 26.1, radius: 10)
        )
        let translated = translator.translate(notam)

        let coordSection = translated.sections.first { $0.title == "Coordinates" }
        XCTAssertNotNil(coordSection)
        XCTAssertTrue(coordSection!.content.contains("N"))
        XCTAssertTrue(coordSection!.content.contains("E"))
        XCTAssertTrue(coordSection!.content.contains("10 NM"))
    }

    // MARK: - Helpers

    private func createTestNOTAM(
        text: String = "Test NOTAM",
        location: String = "LROP",
        minimumFL: String? = nil,
        maximumFL: String? = nil,
        scope: String? = nil,
        coordinates: Coordinates? = nil
    ) -> NOTAM {
        NOTAM(
            id: "TEST_1",
            series: "A",
            number: "0001/24",
            type: .new,
            issued: Date(),
            affectedFIR: location,
            selectionCode: nil,
            traffic: nil,
            purpose: nil,
            scope: scope,
            minimumFL: minimumFL,
            maximumFL: maximumFL,
            location: location,
            effectiveStart: Date(),
            effectiveEnd: Date().addingTimeInterval(86400),
            isEstimatedEnd: false,
            isPermanent: false,
            text: text,
            coordinates: coordinates
        )
    }
}
