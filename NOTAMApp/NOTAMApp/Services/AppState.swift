import Foundation
import Combine
import os.log

private let logger = Logger(subsystem: "com.notamapp.NOTAMApp", category: "AppState")

/// Main application state managing NOTAMs and UI state
@MainActor
final class AppState: ObservableObject {
    // MARK: - Published State

    @Published var notams: [String: [NOTAM]] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    @Published var lastRefreshDate: Date?
    @Published var selectedTab: Tab = .notams
    @Published var selectedNotamId: String?

    // MARK: - Services

    private let notamService = NOTAMService.shared
    private let cache = NOTAMCache.shared
    private let settingsStore = SettingsStore.shared
    private let translator = NOTAMTranslator.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var allNotams: [NOTAM] {
        notams.values.flatMap { $0 }.sorted { $0.effectiveStart > $1.effectiveStart }
    }

    var notamsByFIR: [(fir: String, notams: [NOTAM])] {
        settingsStore.settings.enabledFIRs.compactMap { fir in
            guard let firNotams = notams[fir.icaoCode], !firNotams.isEmpty else { return nil }
            return (fir.icaoCode, firNotams.sorted { $0.effectiveStart > $1.effectiveStart })
        }
    }

    var hasNotams: Bool {
        !allNotams.isEmpty
    }

    // MARK: - Initialization

    init() {
        setupBindings()
        Task {
            await loadCachedData()
        }
    }

    private func setupBindings() {
        // Listen for notification taps
        NotificationCenter.default.publisher(for: .didTapNotification)
            .compactMap { $0.userInfo?["notamId"] as? String }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notamId in
                self?.selectedNotamId = notamId
                self?.selectedTab = .notams
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Loading

    func loadCachedData() async {
        do {
            let cached = try await cache.loadAll()
            for (fir, entry) in cached {
                notams[fir] = entry.notams
            }
            lastRefreshDate = settingsStore.settings.lastRefreshDate
        } catch {
            print("Failed to load cached data: \(error)")
        }
    }

    func refresh() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        do {
            let locations = settingsStore.settings.enabledFIRs.map { $0.icaoCode }
            logger.info("[AppState] Refreshing with FIRs: \(locations.description)")
            guard !locations.isEmpty else {
                logger.info("[AppState] No FIRs configured, aborting refresh")
                isLoading = false
                return
            }

            // Store previous for comparison
            let previousNotams = notams

            // Fetch new data
            logger.info("[AppState] Calling notamService.fetchNOTAMs...")
            let fetched = try await notamService.fetchNOTAMs(for: locations)
            logger.info("[AppState] Received \(fetched.count) FIRs with NOTAMs")

            // Update state
            notams = fetched

            // Save to cache
            for (fir, firNotams) in fetched {
                try await cache.save(notams: firNotams, for: fir)
            }

            // Detect and store changes
            let changes = NOTAMChangeDetector.shared.detectChanges(
                previous: previousNotams,
                current: fetched
            )

            if !changes.isEmpty {
                await ChangeStore.shared.addChanges(changes)
            }

            // Update last refresh
            settingsStore.updateLastRefreshDate()
            lastRefreshDate = Date()

            // Schedule next background refresh
            BackgroundRefreshManager.shared.scheduleRefresh()

        } catch {
            logger.error("[AppState] Refresh error: \(error.localizedDescription)")
            self.error = error
        }

        isLoading = false
    }

    // MARK: - Translation

    func translate(_ notam: NOTAM) -> TranslatedNOTAM {
        translator.translate(notam)
    }

    // MARK: - Selection

    func findNotam(by id: String) -> NOTAM? {
        allNotams.first { $0.id == id }
    }

    func clearError() {
        error = nil
    }
}

// MARK: - Tab

enum Tab: String, CaseIterable {
    case notams = "NOTAMs"
    case changes = "Changes"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .notams: return "doc.text"
        case .changes: return "bell"
        case .settings: return "gear"
        }
    }
}
