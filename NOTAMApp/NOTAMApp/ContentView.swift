import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var changeStore = ChangeStore.shared
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NOTAMListView()
                .tabItem {
                    Label(Tab.notams.rawValue, systemImage: Tab.notams.icon)
                }
                .tag(Tab.notams)

            ChangesListView()
                .tabItem {
                    Label(Tab.changes.rawValue, systemImage: Tab.changes.icon)
                }
                .tag(Tab.changes)
                .badge(changeStore.unreadCount)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .task {
            // Request notification permissions on first launch
            if notificationManager.authorizationStatus == .notDetermined {
                _ = await notificationManager.requestAuthorization()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
