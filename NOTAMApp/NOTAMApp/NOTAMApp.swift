import SwiftUI
import BackgroundTasks
import UserNotifications

@main
struct NOTAMApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    setupBackgroundTasks()
                }
                .task {
                    await appState.refresh()
                }
        }
    }

    private func setupBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundRefreshManager.taskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            BackgroundRefreshManager.shared.handleBackgroundRefresh(task: refreshTask)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let notamId = response.notification.request.content.userInfo["notamId"] as? String {
            NotificationCenter.default.post(
                name: .didTapNotification,
                object: nil,
                userInfo: ["notamId": notamId]
            )
        }
        completionHandler()
    }
}

extension Notification.Name {
    static let didTapNotification = Notification.Name("didTapNotification")
}
