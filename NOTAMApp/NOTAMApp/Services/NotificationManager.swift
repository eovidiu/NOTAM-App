import Foundation
import UserNotifications

/// Manages local notifications for NOTAM changes
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    init() {
        Task {
            await refreshAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.authorizationStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        await MainActor.run {
            self.authorizationStatus = settings.authorizationStatus
        }
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    // MARK: - Notifications

    func notifyOfChanges(_ changes: [NOTAMChange]) async {
        guard isAuthorized else { return }

        let settings = SettingsStore.shared.settings
        guard settings.notificationsEnabled else { return }

        // Group changes by FIR
        let grouped = Dictionary(grouping: changes, by: { $0.notam.affectedFIR })

        for (fir, firChanges) in grouped {
            await sendNotification(for: fir, changes: firChanges, playSound: settings.notificationSound)
        }
    }

    private func sendNotification(for fir: String, changes: [NOTAMChange], playSound: Bool) async {
        let content = UNMutableNotificationContent()

        let newCount = changes.filter { $0.changeType == .new }.count
        let modifiedCount = changes.filter { $0.changeType == .modified }.count
        let expiredCount = changes.filter { $0.changeType == .expired || $0.changeType == .cancelled }.count

        content.title = "NOTAM Update: \(fir)"

        var bodyParts: [String] = []
        if newCount > 0 {
            bodyParts.append("\(newCount) new")
        }
        if modifiedCount > 0 {
            bodyParts.append("\(modifiedCount) modified")
        }
        if expiredCount > 0 {
            bodyParts.append("\(expiredCount) expired")
        }

        content.body = bodyParts.joined(separator: ", ")

        if playSound {
            content.sound = .default
        }

        content.badge = NSNumber(value: changes.count)

        // Add deep link info
        if let firstChange = changes.first {
            content.userInfo = [
                "fir": fir,
                "notamId": firstChange.notam.id,
                "changeCount": changes.count
            ]
        }

        // Use thread identifier for grouping
        content.threadIdentifier = "notam-\(fir)"

        let request = UNNotificationRequest(
            identifier: "notam-\(fir)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // Deliver immediately
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    func removeAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        clearBadge()
    }

    // MARK: - Test Notification

    func sendTestNotification() async {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "NOTAM Test"
        content.body = "Notifications are working correctly!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "test-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to send test notification: \(error)")
        }
    }
}
