import Foundation

/// Manages persistence of detected NOTAM changes
@MainActor
class ChangeStore: ObservableObject {
    static let shared = ChangeStore()

    private let fileManager = FileManager.default
    private let changesFileURL: URL

    @Published private(set) var changes: [NOTAMChange] = []

    var unreadCount: Int {
        changes.filter { !$0.isRead }.count
    }

    init() {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        changesFileURL = paths[0].appendingPathComponent("notam_changes.json")
        load()
    }

    // MARK: - Operations

    func addChanges(_ newChanges: [NOTAMChange]) {
        changes.insert(contentsOf: newChanges, at: 0)

        // Keep only last 100 changes
        if changes.count > 100 {
            changes = Array(changes.prefix(100))
        }

        save()
    }

    func markAsRead(_ change: NOTAMChange) {
        if let index = changes.firstIndex(where: { $0.id == change.id }) {
            changes[index].isRead = true
            save()
        }
    }

    func markAllAsRead() {
        for index in changes.indices {
            changes[index].isRead = true
        }
        save()
    }

    func clearAll() {
        changes = []
        try? fileManager.removeItem(at: changesFileURL)
    }

    func removeChange(_ change: NOTAMChange) {
        changes.removeAll { $0.id == change.id }
        save()
    }

    // MARK: - Persistence

    private func load() {
        guard fileManager.fileExists(atPath: changesFileURL.path) else { return }

        do {
            let data = try Data(contentsOf: changesFileURL)
            let decoded = try JSONDecoder().decode([NOTAMChange].self, from: data)
            self.changes = decoded
        } catch {
            print("Failed to load changes: \(error)")
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(changes)
            try data.write(to: changesFileURL)
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}
