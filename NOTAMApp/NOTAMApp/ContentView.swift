import SwiftUI

/// Aviation Glass Main Content View
/// Premium tab bar interface with Electric Cyan accent
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var changeStore = ChangeStore.shared
    @StateObject private var notificationManager = NotificationManager.shared

    init() {
        // Configure tab bar appearance
        configureTabBarAppearance()
    }

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
        .tint(Color("ElectricCyan"))
        .task {
            // Request notification permissions on first launch
            if notificationManager.authorizationStatus == .notDetermined {
                _ = await notificationManager.requestAuthorization()
            }
        }
    }

    private func configureTabBarAppearance() {
        // Configure tab bar for Aviation Glass style
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Background color - Obsidian
        appearance.backgroundColor = UIColor(Color("Obsidian"))

        // Unselected item color - TextDisabled
        let unselectedColor = UIColor(Color("TextDisabled"))
        appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: unselectedColor
        ]

        // Selected item color - ElectricCyan
        let selectedColor = UIColor(Color("ElectricCyan"))
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor
        ]

        // Badge styling - Electric Cyan
        appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = UIColor(Color("ElectricCyan"))
        appearance.stackedLayoutAppearance.selected.badgeBackgroundColor = UIColor(Color("ElectricCyan"))

        // Apply the appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        // Add subtle top border
        UITabBar.appearance().layer.borderWidth = 0.5
        UITabBar.appearance().layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
