import XCTest
@testable import NOTAMApp

final class NOTAMTests: XCTestCase {

    // MARK: - NOTAM Model Tests

    func testNOTAMDecoding() throws {
        let json = """
        {
            "id": "NOTAM_1_70015719",
            "series": "M",
            "number": "0483/23",
            "type": "N",
            "issued": "2023-10-24T21:45:00.000Z",
            "affectedFIR": "LROP",
            "location": "LROP",
            "effectiveStart": "2023-10-24T21:45:00.000Z",
            "effectiveEnd": "2024-01-19T23:59:00.000Z",
            "icaoMessage": "RWY 08R/26L CLSD DUE TO MAINT"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let item = try decoder.decode(NOTAMResponseItem.self, from: json)

        XCTAssertEqual(item.id, "NOTAM_1_70015719")
        XCTAssertEqual(item.series, "M")
        XCTAssertEqual(item.number, "0483/23")
        XCTAssertEqual(item.location, "LROP")

        let notam = item.toNOTAM()
        XCTAssertNotNil(notam)
        XCTAssertEqual(notam?.displayId, "M0483/23")
        XCTAssertEqual(notam?.location, "LROP")
    }

    func testNOTAMDisplayId() {
        let notam = createTestNOTAM(series: "A", number: "0123/24")
        XCTAssertEqual(notam.displayId, "A0123/24")
    }

    func testNOTAMIsActive() {
        // Active NOTAM (current date within effective period)
        let activeNotam = createTestNOTAM(
            effectiveStart: Date().addingTimeInterval(-3600),
            effectiveEnd: Date().addingTimeInterval(3600)
        )
        XCTAssertTrue(activeNotam.isActive)

        // Expired NOTAM
        let expiredNotam = createTestNOTAM(
            effectiveStart: Date().addingTimeInterval(-7200),
            effectiveEnd: Date().addingTimeInterval(-3600)
        )
        XCTAssertFalse(expiredNotam.isActive)

        // Future NOTAM
        let futureNotam = createTestNOTAM(
            effectiveStart: Date().addingTimeInterval(3600),
            effectiveEnd: Date().addingTimeInterval(7200)
        )
        XCTAssertFalse(futureNotam.isActive)

        // Permanent NOTAM
        let permanentNotam = createTestNOTAM(isPermanent: true)
        XCTAssertTrue(permanentNotam.isActive)
    }

    func testNOTAMType() {
        XCTAssertEqual(NOTAMType.new.rawValue, "N")
        XCTAssertEqual(NOTAMType.replacement.rawValue, "R")
        XCTAssertEqual(NOTAMType.cancellation.rawValue, "C")

        XCTAssertEqual(NOTAMType.new.displayName, "New")
        XCTAssertEqual(NOTAMType.replacement.displayName, "Replacement")
        XCTAssertEqual(NOTAMType.cancellation.displayName, "Cancellation")
    }

    // MARK: - FIR Model Tests

    func testFIRValidation() {
        XCTAssertTrue(FIR.isValidICAOCode("LROP"))
        XCTAssertTrue(FIR.isValidICAOCode("KJFK"))
        XCTAssertTrue(FIR.isValidICAOCode("EGLL"))

        XCTAssertFalse(FIR.isValidICAOCode("LRO"))    // Too short
        XCTAssertFalse(FIR.isValidICAOCode("LROPP"))  // Too long
        XCTAssertFalse(FIR.isValidICAOCode("LR0P"))   // Contains number
        XCTAssertFalse(FIR.isValidICAOCode(""))       // Empty
    }

    func testFIRInitialization() {
        let fir = FIR(icaoCode: "lrop", displayName: "Bucharest")
        XCTAssertEqual(fir.icaoCode, "LROP") // Should be uppercased
        XCTAssertEqual(fir.displayName, "Bucharest")
        XCTAssertTrue(fir.isEnabled)
        XCTAssertTrue(fir.isValidICAO)
    }

    func testDefaultFIR() {
        let defaultFIR = FIR.defaultFIR
        XCTAssertEqual(defaultFIR.icaoCode, "LROP")
        XCTAssertTrue(defaultFIR.isEnabled)
    }

    // MARK: - AppSettings Tests

    func testAppSettingsDefaults() {
        let settings = AppSettings.default
        XCTAssertEqual(settings.configuredFIRs.count, 1)
        XCTAssertEqual(settings.configuredFIRs.first?.icaoCode, "LROP")
        XCTAssertEqual(settings.refreshInterval, .sixHours)
        XCTAssertTrue(settings.notificationsEnabled)
        XCTAssertTrue(settings.notificationSound)
    }

    func testRefreshInterval() {
        XCTAssertEqual(RefreshInterval.oneHour.seconds, 3600)
        XCTAssertEqual(RefreshInterval.sixHours.seconds, 3600 * 6)
        XCTAssertEqual(RefreshInterval.twelveHours.seconds, 3600 * 12)
    }

    func testEnabledFIRs() {
        var settings = AppSettings.default
        settings.configuredFIRs = [
            FIR(icaoCode: "LROP", isEnabled: true),
            FIR(icaoCode: "KJFK", isEnabled: false),
            FIR(icaoCode: "EGLL", isEnabled: true)
        ]

        XCTAssertEqual(settings.enabledFIRs.count, 2)
        XCTAssertTrue(settings.enabledFIRs.contains { $0.icaoCode == "LROP" })
        XCTAssertTrue(settings.enabledFIRs.contains { $0.icaoCode == "EGLL" })
        XCTAssertFalse(settings.enabledFIRs.contains { $0.icaoCode == "KJFK" })
    }

    // MARK: - NOTAMChange Tests

    func testNOTAMChangeSummary() {
        let notam = createTestNOTAM(location: "LROP")

        let newChange = NOTAMChange(changeType: .new, notam: notam)
        XCTAssertTrue(newChange.summary.contains("New"))
        XCTAssertTrue(newChange.summary.contains("LROP"))

        let expiredChange = NOTAMChange(changeType: .expired, notam: notam)
        XCTAssertTrue(expiredChange.summary.contains("Expired"))

        let modifiedChange = NOTAMChange(changeType: .modified, notam: notam)
        XCTAssertTrue(modifiedChange.summary.contains("Modified"))

        let cancelledChange = NOTAMChange(changeType: .cancelled, notam: notam)
        XCTAssertTrue(cancelledChange.summary.contains("Cancelled"))
    }

    func testChangeTypeIcons() {
        XCTAssertEqual(ChangeType.new.iconName, "plus.circle.fill")
        XCTAssertEqual(ChangeType.expired.iconName, "clock.badge.xmark.fill")
        XCTAssertEqual(ChangeType.modified.iconName, "pencil.circle.fill")
        XCTAssertEqual(ChangeType.cancelled.iconName, "xmark.circle.fill")
    }

    // MARK: - Helpers

    private func createTestNOTAM(
        id: String = "TEST_1",
        series: String = "A",
        number: String = "0001/24",
        type: NOTAMType = .new,
        location: String = "LROP",
        effectiveStart: Date = Date(),
        effectiveEnd: Date? = nil,
        isPermanent: Bool = false,
        text: String = "Test NOTAM"
    ) -> NOTAM {
        NOTAM(
            id: id,
            series: series,
            number: number,
            type: type,
            issued: Date(),
            affectedFIR: location,
            selectionCode: nil,
            traffic: nil,
            purpose: nil,
            scope: nil,
            minimumFL: nil,
            maximumFL: nil,
            location: location,
            effectiveStart: effectiveStart,
            effectiveEnd: effectiveEnd,
            isEstimatedEnd: false,
            isPermanent: isPermanent,
            text: text,
            coordinates: nil
        )
    }
}
