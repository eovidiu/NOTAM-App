import Foundation

/// Manages persistence of detected NOTAM changes
actor ChangeStore {
    static let shared = ChangeStore()

    private let fileManager = FileManager.default
    private let changesFileURL: URL

    @MainActor @Published private(set) var changes: [NOTAMChange] = []
    @MainActor var unreadCount: Int {
        changes.filter { !$0.isRead }.count
    }

    init() {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        changesFileURL = paths[0].appendingPathComponent("notam_changes.json")

        Task {
            await load()
        }
    }

    // MARK: - Operations

    func addChanges(_ newChanges: [NOTAMChange]) async {
        var current = await MainActor.run { changes }
        current.insert(contentsOf: newChanges, at: 0)

        // Keep only last 100 changes
        if current.count > 100 {
            current = Array(current.prefix(100))
        }

        await MainActor.run {
            self.changes = current
        }

        save(current)
    }

    func markAsRead(_ change: NOTAMChange) async {
        var current = await MainActor.run { changes }
        if let index = current.firstIndex(where: { $0.id == change.id }) {
            current[index].isRead = true
            await MainActor.run {
                self.changes = current
            }
            save(current)
        }
    }

    func markAllAsRead() async {
        var current = await MainActor.run { changes }
        for index in current.indices {
            current[index].isRead = true
        }
        await MainActor.run {
            self.changes = current
        }
        save(current)
    }

    func clearAll() async {
        await MainActor.run {
            self.changes = []
        }
        try? fileManager.removeItem(at: changesFileURL)
    }

    func removeChange(_ change: NOTAMChange) async {
        var current = await MainActor.run { changes }
        current.removeAll { $0.id == change.id }
        await MainActor.run {
            self.changes = current
        }
        save(current)
    }

    // MARK: - Persistence

    private func load() async {
        guard fileManager.fileExists(atPath: changesFileURL.path) else { return }

        do {
            let data = try Data(contentsOf: changesFileURL)
            let decoded = try JSONDecoder().decode([NOTAMChange].self, from: data)
            await MainActor.run {
                self.changes = decoded
            }
        } catch {
            print("Failed to load changes: \(error)")
        }
    }

    private func save(_ changes: [NOTAMChange]) {
        do {
            let data = try JSONEncoder().encode(changes)
            try data.write(to: changesFileURL)
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}
