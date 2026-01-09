import Foundation
import BackgroundTasks
import UIKit

/// Manages background refresh of NOTAM data
final class BackgroundRefreshManager {
    static let shared = BackgroundRefreshManager()
    static let taskIdentifier = "com.notamapp.refresh"

    private let notamService = NOTAMService.shared
    private let cache = NOTAMCache.shared
    private let changeDetector = NOTAMChangeDetector.shared
    private let notificationManager = NotificationManager.shared

    // MARK: - Scheduling

    func scheduleRefresh() {
        let settings = SettingsStore.shared.settings
        let interval = settings.refreshInterval.seconds

        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: interval)

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background refresh scheduled for \(interval / 3600) hours from now")
        } catch {
            print("Failed to schedule background refresh: \(error)")
        }
    }

    func cancelScheduledRefresh() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.taskIdentifier)
    }

    // MARK: - Task Handling

    func handleBackgroundRefresh(task: BGAppRefreshTask) {
        // Schedule the next refresh
        scheduleRefresh()

        // Create a task to do the work
        let refreshTask = Task {
            await performRefresh()
        }

        // Handle task expiration
        task.expirationHandler = {
            refreshTask.cancel()
        }

        // Wait for completion
        Task {
            await refreshTask.value
            task.setTaskCompleted(success: !refreshTask.isCancelled)
        }
    }

    // MARK: - Critical NOTAM Notifications

    /// Check for NOTAMs that meet severity threshold and need notification
    private func checkAndNotifyCriticalNOTAMs(_ notams: [String: [NOTAM]]) async {
        let store = NotifiedNOTAMStore.shared
        let settings = SettingsStore.shared.settings
        let threshold = settings.notificationSeverityThreshold
        let threeDaysAgo = Date().addingTimeInterval(-3 * 24 * 60 * 60)

        for (_, firNotams) in notams {
            for notam in firNotams {
                // Must meet severity threshold
                guard notam.severity.meetsThreshold(threshold) else { continue }

                // Must be issued within last 3 days
                guard notam.issued > threeDaysAgo else { continue }

                // Must not have been notified before
                guard !store.hasBeenNotified(notam.id) else { continue }

                // Send notification
                await notificationManager.sendCriticalAirspaceNotification(for: notam)

                // Mark as notified
                store.markAsNotified(notam.id)
            }
        }
    }

    // MARK: - Manual Refresh

    func performRefresh() async {
        let settings = SettingsStore.shared.settings
        let locations = settings.enabledFIRs.map { $0.icaoCode }

        guard !locations.isEmpty else { return }

        do {
            // Load cached NOTAMs for comparison
            let cachedData = try await cache.loadAll()
            var previousNOTAMs: [String: [NOTAM]] = [:]
            for (fir, entry) in cachedData {
                previousNOTAMs[fir] = entry.notams
            }

            // Fetch new NOTAMs
            let newNOTAMs = try await notamService.fetchNOTAMs(for: locations)

            // Save to cache
            for (fir, notams) in newNOTAMs {
                try await cache.save(notams: notams, for: fir)
            }

            // Check for critical NOTAMs requiring immediate notification
            if settings.notificationsEnabled {
                await checkAndNotifyCriticalNOTAMs(newNOTAMs)
            }

            // Detect changes
            let changes = changeDetector.detectChanges(
                previous: previousNOTAMs,
                current: newNOTAMs
            )

            // Update last refresh date
            await MainActor.run {
                SettingsStore.shared.updateLastRefreshDate()
            }

            // Notify user of changes
            if !changes.isEmpty && settings.notificationsEnabled {
                await notificationManager.notifyOfChanges(changes)
            }

            // Save changes for display
            await ChangeStore.shared.addChanges(changes)

        } catch {
            print("Background refresh failed: \(error)")
        }
    }
}
