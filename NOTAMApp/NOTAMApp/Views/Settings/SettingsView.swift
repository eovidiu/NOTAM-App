import SwiftUI

/// Aviation Glass Settings View
/// Premium settings interface with glass morphism styling
struct SettingsView: View {
    @StateObject private var settingsStore = SettingsStore.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showAddFIR = false
    @State private var showLocateFIRs = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color("DeepSpace")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AviationTheme.Spacing.lg) {
                        // FIR Configuration
                        firSection

                        // Refresh Settings
                        refreshSection

                        // Notifications
                        notificationSection

                        // About
                        aboutSection
                    }
                    .padding(AviationTheme.Spacing.md)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("DeepSpace"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showAddFIR) {
                AddFIRView()
            }
            .sheet(isPresented: $showLocateFIRs) {
                LocateFIRsView()
            }
        }
    }

    // MARK: - FIR Section

    private var firSection: some View {
        VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
            SimpleSectionHeader(
                title: "FLIGHT INFORMATION REGIONS",
                subtitle: "Tap to enable/disable, swipe to delete"
            )

            if settingsStore.settings.configuredFIRs.isEmpty {
                GlassCard {
                    Text("No FIRs configured")
                        .font(AviationFont.bodySecondary())
                        .foregroundStyle(Color("TextDisabled"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AviationTheme.Spacing.md)
                }
            } else {
                // Use List for native swipe-to-delete support
                List {
                    ForEach(settingsStore.settings.configuredFIRs) { fir in
                        FIRRowView(fir: fir) {
                            HapticManager.shared.light()
                            settingsStore.toggleFIR(fir)
                        }
                        .listRowBackground(Color("Graphite"))
                        .listRowSeparatorTint(Color.white.opacity(0.1))
                    }
                    .onDelete { indexSet in
                        HapticManager.shared.medium()
                        for index in indexSet {
                            let fir = settingsStore.settings.configuredFIRs[index]
                            settingsStore.removeFIR(fir)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .frame(height: CGFloat(settingsStore.settings.configuredFIRs.count) * 52)
                .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.large))
                .overlay(
                    RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.large)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.white.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            }

            // Action buttons (with top spacing to separate from list)
            HStack(spacing: AviationTheme.Spacing.sm) {
                Button {
                    HapticManager.shared.buttonTap()
                    showAddFIR = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle")
                        Text("Add FIR")
                    }
                    .font(AviationFont.cardTitle())
                    .foregroundStyle(Color("ElectricCyan"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AviationTheme.Spacing.sm)
                    .background(Color("ElectricCyan").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium)
                            .stroke(Color("ElectricCyan").opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Button {
                    HapticManager.shared.buttonTap()
                    showLocateFIRs = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "location.circle")
                        Text("Near Me")
                    }
                    .font(AviationFont.cardTitle())
                    .foregroundStyle(Color("AuroraGreen"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AviationTheme.Spacing.sm)
                    .background(Color("AuroraGreen").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium)
                            .stroke(Color("AuroraGreen").opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.top, AviationTheme.Spacing.xs)
        }
    }

    // MARK: - Refresh Section

    private var refreshSection: some View {
        VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
            SimpleSectionHeader(
                title: "BACKGROUND REFRESH",
                subtitle: "iOS may adjust timing based on usage patterns"
            )

            GlassCard {
                VStack(spacing: AviationTheme.Spacing.sm) {
                    // Refresh interval picker
                    HStack {
                        Text("Refresh Interval")
                            .font(AviationFont.bodyPrimary())
                            .foregroundStyle(Color("TextPrimary"))

                        Spacer()

                        Picker("", selection: Binding(
                            get: { settingsStore.settings.refreshInterval },
                            set: { settingsStore.setRefreshInterval($0) }
                        )) {
                            ForEach(RefreshInterval.allCases) { interval in
                                Text(interval.displayName).tag(interval)
                            }
                        }
                        .tint(Color("ElectricCyan"))
                    }

                    Divider().background(Color.white.opacity(0.1))

                    // Next refresh
                    if let nextRefresh = settingsStore.settings.nextRefreshDate {
                        HStack {
                            Text("Next Refresh")
                                .font(AviationFont.bodySecondary())
                                .foregroundStyle(Color("TextSecondary"))
                            Spacer()
                            Text(nextRefresh, style: .relative)
                                .font(AviationFont.bodySecondary())
                                .foregroundStyle(Color("TextTertiary"))
                        }
                    }

                    // Last refresh
                    if let lastRefresh = settingsStore.settings.lastRefreshDate {
                        HStack {
                            Text("Last Refresh")
                                .font(AviationFont.bodySecondary())
                                .foregroundStyle(Color("TextSecondary"))
                            Spacer()
                            Text(lastRefresh, style: .relative)
                                .font(AviationFont.bodySecondary())
                                .foregroundStyle(Color("TextTertiary"))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
            SimpleSectionHeader(
                title: "NOTIFICATIONS",
                subtitle: "Receive alerts when NOTAMs change"
            )

            GlassCard {
                VStack(spacing: AviationTheme.Spacing.sm) {
                    // Enable toggle
                    Toggle(isOn: Binding(
                        get: { settingsStore.settings.notificationsEnabled },
                        set: { settingsStore.setNotificationsEnabled($0) }
                    )) {
                        Text("Enable Notifications")
                            .font(AviationFont.bodyPrimary())
                            .foregroundStyle(Color("TextPrimary"))
                    }
                    .tint(Color("ElectricCyan"))
                    .disabled(notificationManager.authorizationStatus == .denied)

                    if settingsStore.settings.notificationsEnabled {
                        Divider().background(Color.white.opacity(0.1))

                        // Sound toggle
                        Toggle(isOn: Binding(
                            get: { settingsStore.settings.notificationSound },
                            set: { settingsStore.setNotificationSound($0) }
                        )) {
                            Text("Notification Sound")
                                .font(AviationFont.bodyPrimary())
                                .foregroundStyle(Color("TextPrimary"))
                        }
                        .tint(Color("ElectricCyan"))

                        Divider().background(Color.white.opacity(0.1))

                        // Severity picker
                        HStack {
                            Text("Minimum Severity")
                                .font(AviationFont.bodyPrimary())
                                .foregroundStyle(Color("TextPrimary"))

                            Spacer()

                            Picker("", selection: Binding(
                                get: { settingsStore.settings.notificationSeverityThreshold },
                                set: { settingsStore.setNotificationSeverityThreshold($0) }
                            )) {
                                Text("Critical Only").tag(NOTAMSeverity.critical)
                                Text("Caution+").tag(NOTAMSeverity.caution)
                            }
                            .tint(Color("ElectricCyan"))
                        }
                    }

                    // Permission warning
                    if notificationManager.authorizationStatus == .denied {
                        Divider().background(Color.white.opacity(0.1))

                        Button {
                            openAppSettings()
                        } label: {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(Color("AmberAlert"))
                                Text("Notifications Disabled")
                                    .font(AviationFont.bodyPrimary())
                                    .foregroundStyle(Color("TextPrimary"))
                                Spacer()
                                Text("Open Settings")
                                    .font(AviationFont.bodySecondary())
                                    .foregroundStyle(Color("ElectricCyan"))
                            }
                        }
                        .buttonStyle(.plain)
                    } else if notificationManager.authorizationStatus == .notDetermined {
                        Divider().background(Color.white.opacity(0.1))

                        Button {
                            Task {
                                _ = await notificationManager.requestAuthorization()
                            }
                        } label: {
                            Text("Request Permission")
                                .font(AviationFont.bodyPrimary())
                                .foregroundStyle(Color("ElectricCyan"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }

                    // Test notification
                    if notificationManager.isAuthorized {
                        Divider().background(Color.white.opacity(0.1))

                        Button {
                            HapticManager.shared.buttonTap()
                            Task {
                                await notificationManager.sendTestNotification()
                            }
                        } label: {
                            Text("Send Test Notification")
                                .font(AviationFont.bodyPrimary())
                                .foregroundStyle(Color("ElectricCyan"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
            SimpleSectionHeader(title: "ABOUT")

            GlassCard {
                VStack(spacing: AviationTheme.Spacing.sm) {
                    // Version
                    HStack {
                        Text("Version")
                            .font(AviationFont.bodyPrimary())
                            .foregroundStyle(Color("TextPrimary"))
                        Spacer()
                        Text("1.0.0")
                            .font(AviationFont.rawText())
                            .foregroundStyle(Color("TextTertiary"))
                    }

                    Divider().background(Color.white.opacity(0.1))

                    // FAA Link
                    Link(destination: URL(string: "https://notams.aim.faa.gov")!) {
                        HStack {
                            Text("FAA NOTAM Search")
                                .font(AviationFont.bodyPrimary())
                                .foregroundStyle(Color("TextPrimary"))
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(Color("TextTertiary"))
                        }
                    }

                    Divider().background(Color.white.opacity(0.1))

                    // Clear cache
                    Button {
                        HapticManager.shared.buttonTap()
                        Task {
                            try? await NOTAMCache.shared.clearAll()
                        }
                    } label: {
                        Text("Clear Cache")
                            .font(AviationFont.bodyPrimary())
                            .foregroundStyle(Color("CrimsonPulse"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

/// Aviation Glass FIR Row View
struct FIRRowView: View {
    let fir: FIR
    let toggleAction: () -> Void

    var body: some View {
        Button(action: toggleAction) {
            HStack(spacing: AviationTheme.Spacing.sm) {
                // FIR Code badge
                FIRCodePill(code: fir.icaoCode, style: .standard)

                // Name (if different from code)
                if fir.displayName != fir.icaoCode {
                    Text(fir.displayName)
                        .font(AviationFont.bodySecondary())
                        .foregroundStyle(Color("TextSecondary"))
                        .lineLimit(1)
                }

                Spacer()

                // Enable/Disable indicator
                Image(systemName: fir.isEnabled ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(fir.isEnabled ? Color("AuroraGreen") : Color("TextDisabled"))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
}
