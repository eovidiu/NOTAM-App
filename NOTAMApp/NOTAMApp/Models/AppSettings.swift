import Foundation

/// App-wide settings
struct AppSettings: Codable {
    var configuredFIRs: [FIR]
    var refreshInterval: RefreshInterval
    var notificationsEnabled: Bool
    var notificationSound: Bool
    var lastRefreshDate: Date?

    init(
        configuredFIRs: [FIR] = [.defaultFIR],
        refreshInterval: RefreshInterval = .sixHours,
        notificationsEnabled: Bool = true,
        notificationSound: Bool = true,
        lastRefreshDate: Date? = nil
    ) {
        self.configuredFIRs = configuredFIRs
        self.refreshInterval = refreshInterval
        self.notificationsEnabled = notificationsEnabled
        self.notificationSound = notificationSound
        self.lastRefreshDate = lastRefreshDate
    }

    var enabledFIRs: [FIR] {
        configuredFIRs.filter { $0.isEnabled }
    }

    var nextRefreshDate: Date? {
        guard let last = lastRefreshDate else { return nil }
        return last.addingTimeInterval(refreshInterval.seconds)
    }

    static let `default` = AppSettings()
}

enum RefreshInterval: String, Codable, CaseIterable, Identifiable {
    case oneHour = "1h"
    case sixHours = "6h"
    case twelveHours = "12h"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oneHour: return "Every hour"
        case .sixHours: return "Every 6 hours"
        case .twelveHours: return "Every 12 hours"
        }
    }

    var seconds: TimeInterval {
        switch self {
        case .oneHour: return 3600
        case .sixHours: return 3600 * 6
        case .twelveHours: return 3600 * 12
        }
    }
}
