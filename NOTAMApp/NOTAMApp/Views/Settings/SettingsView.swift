import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsStore = SettingsStore.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showAddFIR = false

    var body: some View {
        NavigationStack {
            Form {
                // FIR Configuration
                firSection

                // Refresh Settings
                refreshSection

                // Notifications
                notificationSection

                // About
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAddFIR) {
                AddFIRView()
            }
        }
    }

    // MARK: - FIR Section

    private var firSection: some View {
        Section {
            ForEach(settingsStore.settings.configuredFIRs) { fir in
                FIRRowView(fir: fir) {
                    settingsStore.toggleFIR(fir)
                }
            }
            .onDelete { offsets in
                settingsStore.removeFIR(at: offsets)
            }
            .onMove { source, destination in
                settingsStore.moveFIR(from: source, to: destination)
            }

            Button {
                showAddFIR = true
            } label: {
                Label("Add FIR", systemImage: "plus.circle")
            }
        } header: {
            Text("Flight Information Regions")
        } footer: {
            Text("Configure the FIRs you want to monitor for NOTAMs. Tap to enable/disable, swipe to delete.")
        }
    }

    // MARK: - Refresh Section

    private var refreshSection: some View {
        Section {
            Picker("Refresh Interval", selection: Binding(
                get: { settingsStore.settings.refreshInterval },
                set: { settingsStore.setRefreshInterval($0) }
            )) {
                ForEach(RefreshInterval.allCases) { interval in
                    Text(interval.displayName).tag(interval)
                }
            }

            if let nextRefresh = settingsStore.settings.nextRefreshDate {
                HStack {
                    Text("Next Refresh")
                    Spacer()
                    Text(nextRefresh, style: .relative)
                        .foregroundStyle(.secondary)
                }
            }

            if let lastRefresh = settingsStore.settings.lastRefreshDate {
                HStack {
                    Text("Last Refresh")
                    Spacer()
                    Text(lastRefresh, style: .relative)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Background Refresh")
        } footer: {
            Text("NOTAMs are refreshed automatically in the background. iOS may adjust timing based on your usage patterns.")
        }
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        Section {
            Toggle("Enable Notifications", isOn: Binding(
                get: { settingsStore.settings.notificationsEnabled },
                set: { settingsStore.setNotificationsEnabled($0) }
            ))
            .disabled(notificationManager.authorizationStatus == .denied)

            if settingsStore.settings.notificationsEnabled {
                Toggle("Notification Sound", isOn: Binding(
                    get: { settingsStore.settings.notificationSound },
                    set: { settingsStore.setNotificationSound($0) }
                ))

                Picker("Minimum Severity", selection: Binding(
                    get: { settingsStore.settings.notificationSeverityThreshold },
                    set: { settingsStore.setNotificationSeverityThreshold($0) }
                )) {
                    Text("Critical Only").tag(NOTAMSeverity.critical)
                    Text("Caution and Above").tag(NOTAMSeverity.caution)
                }
            }

            if notificationManager.authorizationStatus == .denied {
                Button {
                    openAppSettings()
                } label: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                        Text("Notifications Disabled")
                        Spacer()
                        Text("Open Settings")
                            .foregroundStyle(.blue)
                    }
                }
            } else if notificationManager.authorizationStatus == .notDetermined {
                Button("Request Permission") {
                    Task {
                        _ = await notificationManager.requestAuthorization()
                    }
                }
            }

            if notificationManager.isAuthorized {
                Button("Send Test Notification") {
                    Task {
                        await notificationManager.sendTestNotification()
                    }
                }
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Receive notifications when NOTAMs change for your configured FIRs.")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }

            Link(destination: URL(string: "https://notams.aim.faa.gov")!) {
                HStack {
                    Text("FAA NOTAM Search")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }

            Button("Clear Cache") {
                Task {
                    try? await NOTAMCache.shared.clearAll()
                }
            }
            .foregroundStyle(.red)
        } header: {
            Text("About")
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct FIRRowView: View {
    let fir: FIR
    let toggleAction: () -> Void

    var body: some View {
        Button(action: toggleAction) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(fir.icaoCode)
                        .font(.headline.monospaced())

                    if fir.displayName != fir.icaoCode {
                        Text(fir.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: fir.isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(fir.isEnabled ? .green : .secondary)
                    .font(.title3)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
}
