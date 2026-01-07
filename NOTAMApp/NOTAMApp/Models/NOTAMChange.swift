import Foundation

/// Represents a detected change in NOTAM data
struct NOTAMChange: Codable, Identifiable, Hashable {
    let id: UUID
    let changeType: ChangeType
    let notam: NOTAM
    let previousNotam: NOTAM?
    let detectedAt: Date
    var isRead: Bool

    init(
        id: UUID = UUID(),
        changeType: ChangeType,
        notam: NOTAM,
        previousNotam: NOTAM? = nil,
        detectedAt: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.changeType = changeType
        self.notam = notam
        self.previousNotam = previousNotam
        self.detectedAt = detectedAt
        self.isRead = isRead
    }

    var summary: String {
        switch changeType {
        case .new:
            return "New NOTAM: \(notam.displayId) for \(notam.location)"
        case .expired:
            return "Expired: \(notam.displayId) for \(notam.location)"
        case .modified:
            return "Modified: \(notam.displayId) for \(notam.location)"
        case .cancelled:
            return "Cancelled: \(notam.displayId) for \(notam.location)"
        }
    }

    var detailedDescription: String {
        switch changeType {
        case .new:
            return "A new NOTAM has been issued for \(notam.location). Effective from \(notam.effectivePeriodDescription)."
        case .expired:
            return "NOTAM \(notam.displayId) has expired and is no longer active."
        case .modified:
            return "NOTAM \(notam.displayId) has been updated. Please review the changes."
        case .cancelled:
            return "NOTAM \(notam.displayId) has been cancelled."
        }
    }
}

enum ChangeType: String, Codable {
    case new
    case expired
    case modified
    case cancelled

    var displayName: String {
        switch self {
        case .new: return "New"
        case .expired: return "Expired"
        case .modified: return "Modified"
        case .cancelled: return "Cancelled"
        }
    }

    var iconName: String {
        switch self {
        case .new: return "plus.circle.fill"
        case .expired: return "clock.badge.xmark.fill"
        case .modified: return "pencil.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .new: return "green"
        case .expired: return "gray"
        case .modified: return "orange"
        case .cancelled: return "red"
        }
    }
}
