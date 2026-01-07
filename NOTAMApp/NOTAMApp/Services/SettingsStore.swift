import Foundation
import Combine

/// Manages persistence of app settings using UserDefaults
final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    private let defaults = UserDefaults.standard
    private let settingsKey = "app_settings"

    @Published private(set) var settings: AppSettings {
        didSet {
            save()
        }
    }

    init() {
        self.settings = Self.load(from: UserDefaults.standard, key: "app_settings") ?? .default
    }

    // MARK: - FIR Management

    func addFIR(_ fir: FIR) {
        guard !settings.configuredFIRs.contains(where: { $0.icaoCode == fir.icaoCode }) else { return }
        settings.configuredFIRs.append(fir)
    }

    func removeFIR(at offsets: IndexSet) {
        settings.configuredFIRs.remove(atOffsets: offsets)
        if settings.configuredFIRs.isEmpty {
            settings.configuredFIRs = [.defaultFIR]
        }
    }

    func removeFIR(_ fir: FIR) {
        settings.configuredFIRs.removeAll { $0.id == fir.id }
        if settings.configuredFIRs.isEmpty {
            settings.configuredFIRs = [.defaultFIR]
        }
    }

    func moveFIR(from source: IndexSet, to destination: Int) {
        settings.configuredFIRs.move(fromOffsets: source, toOffset: destination)
    }

    func toggleFIR(_ fir: FIR) {
        guard let index = settings.configuredFIRs.firstIndex(where: { $0.id == fir.id }) else { return }
        settings.configuredFIRs[index].isEnabled.toggle()
    }

    func updateFIR(_ fir: FIR) {
        guard let index = settings.configuredFIRs.firstIndex(where: { $0.id == fir.id }) else { return }
        settings.configuredFIRs[index] = fir
    }

    // MARK: - Refresh Interval

    func setRefreshInterval(_ interval: RefreshInterval) {
        settings.refreshInterval = interval
        BackgroundRefreshManager.shared.scheduleRefresh()
    }

    func updateLastRefreshDate() {
        settings.lastRefreshDate = Date()
    }

    // MARK: - Notifications

    func setNotificationsEnabled(_ enabled: Bool) {
        settings.notificationsEnabled = enabled
    }

    func setNotificationSound(_ enabled: Bool) {
        settings.notificationSound = enabled
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: settingsKey)
    }

    private static func load(from defaults: UserDefaults, key: String) -> AppSettings? {
        guard let data = defaults.data(forKey: key),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return nil
        }
        return settings
    }

    func reset() {
        settings = .default
    }
}
