import XCTest
@testable import NOTAMApp

final class NOTAMChangeDetectorTests: XCTestCase {
    let detector = NOTAMChangeDetector.shared

    // MARK: - New NOTAM Detection

    func testDetectsNewNOTAMs() {
        let previous: [String: [NOTAM]] = [:]
        let current: [String: [NOTAM]] = [
            "LROP": [createTestNOTAM(id: "NEW_1")]
        ]

        let changes = detector.detectChanges(previous: previous, current: current)

        XCTAssertEqual(changes.count, 1)
        XCTAssertEqual(changes.first?.changeType, .new)
        XCTAssertEqual(changes.first?.notam.id, "NEW_1")
    }

    func testDetectsMultipleNewNOTAMs() {
        let previous: [String: [NOTAM]] = [:]
        let current: [String: [NOTAM]] = [
            "LROP": [
                createTestNOTAM(id: "NEW_1"),
                createTestNOTAM(id: "NEW_2"),
                createTestNOTAM(id: "NEW_3")
            ]
        ]

        let changes = detector.detectChanges(previous: previous, current: current)

        XCTAssertEqual(changes.count, 3)
        XCTAssertTrue(changes.allSatisfy { $0.changeType == .new })
    }

    // MARK: - Expired NOTAM Detection

    func testDetectsExpiredNOTAMs() {
        let previous: [String: [NOTAM]] = [
            "LROP": [createTestNOTAM(id: "OLD_1")]
        ]
        let current: [String: [NOTAM]] = [:]

        let changes = detector.detectChanges(previous: previous, current: current)

        XCTAssertEqual(changes.count, 1)
        XCTAssertEqual(changes.first?.changeType, .expired)
        XCTAssertEqual(changes.first?.notam.id, "OLD_1")
    }

    // MARK: - Modified NOTAM Detection

    func testDetectsModifiedNOTAMs() {
        let original = createTestNOTAM(id: "MOD_1", text: "Original text")
        let modified = createTestNOTAM(id: "MOD_1", text: "Modified text")

        let previous: [String: [NOTAM]] = [
            "LROP": [original]
        ]
        let current: [String: [NOTAM]] = [
            "LROP": [modified]
        ]

        let changes = detector.detectChanges(previous: previous, current: current)

        XCTAssertEqual(changes.count, 1)
        XCTAssertEqual(changes.first?.changeType, .modified)
        XCTAssertEqual(changes.first?.notam.id, "MOD_1")
        XCTAssertNotNil(changes.first?.previousNotam)
        XCTAssertEqual(changes.first?.previousNotam?.text, "Original text")
        XCTAssertEqual(changes.first?.notam.text, "Modified text")
    }

    func testNoChangeForIdenticalNOTAMs() {
        let notam = createTestNOTAM(id: "SAME_1", text: "Same text")

        let previous: [String: [NOTAM]] = [
            "LROP": [notam]
        ]
        let current: [String: [NOTAM]] = [
            "LROP": [notam]
        ]

        let changes = detector.detectChanges(previous: previous, current: current)

        XCTAssertTrue(changes.isEmpty)
    }

    // MARK: - Multi-FIR Detection

    func testDetectsChangesAcrossMultipleFIRs() {
        let previous: [String: [NOTAM]] = [
            "LROP": [createTestNOTAM(id: "LROP_1")],
            "KJFK": [createTestNOTAM(id: "KJFK_1")]
        ]
        let current: [String: [NOTAM]] = [
            "LROP": [createTestNOTAM(id: "LROP_2")], // Changed
            "KJFK": [createTestNOTAM(id: "KJFK_1")], // Same
            "EGLL": [createTestNOTAM(id: "EGLL_1")]  // New FIR
        ]

        let changes = detector.detectChanges(previous: previous, current: current)

        // Should detect: LROP_1 expired, LROP_2 new, EGLL_1 new
        XCTAssertEqual(changes.count, 3)

        let newChanges = changes.filter { $0.changeType == .new }
        let expiredChanges = changes.filter { $0.changeType == .expired }

        XCTAssertEqual(newChanges.count, 2)
        XCTAssertEqual(expiredChanges.count, 1)
    }

    // MARK: - Cancellation Detection

    func testDetectsCancellation() {
        let cancelledNotam = createTestNOTAM(id: "CANCEL_1", type: .cancellation)

        let previous: [String: [NOTAM]] = [
            "LROP": [cancelledNotam]
        ]
        let current: [String: [NOTAM]] = [:]

        let changes = detector.detectChanges(previous: previous, current: current)

        XCTAssertEqual(changes.count, 1)
        XCTAssertEqual(changes.first?.changeType, .cancelled)
    }

    // MARK: - Date Change Detection

    func testDetectsEffectiveDateChange() {
        let original = createTestNOTAM(
            id: "DATE_1",
            effectiveStart: Date(),
            effectiveEnd: Date().addingTimeInterval(86400)
        )
        let modified = createTestNOTAM(
            id: "DATE_1",
            effectiveStart: Date(),
            effectiveEnd: Date().addingTimeInterval(86400 * 2) // Extended
        )

        let previous: [String: [NOTAM]] = ["LROP": [original]]
        let current: [String: [NOTAM]] = ["LROP": [modified]]

        let changes = detector.detectChanges(previous: previous, current: current)

        XCTAssertEqual(changes.count, 1)
        XCTAssertEqual(changes.first?.changeType, .modified)
    }

    // MARK: - Helpers

    private func createTestNOTAM(
        id: String = "TEST_1",
        type: NOTAMType = .new,
        text: String = "Test NOTAM",
        effectiveStart: Date = Date(),
        effectiveEnd: Date? = nil
    ) -> NOTAM {
        NOTAM(
            id: id,
            series: "A",
            number: "0001/24",
            type: type,
            issued: Date(),
            affectedFIR: "LROP",
            selectionCode: nil,
            traffic: nil,
            purpose: nil,
            scope: nil,
            minimumFL: nil,
            maximumFL: nil,
            location: "LROP",
            effectiveStart: effectiveStart,
            effectiveEnd: effectiveEnd,
            isEstimatedEnd: false,
            isPermanent: false,
            text: text,
            coordinates: nil
        )
    }
}
