import Foundation

/// Entry tracking a notified NOTAM
struct NotifiedNOTAMEntry: Codable, Equatable {
    let notamId: String
    let notifiedDate: Date
}

/// Tracks which NOTAMs have been notified to prevent duplicate notifications
final class NotifiedNOTAMStore {
    static let shared = NotifiedNOTAMStore()
    
    private let defaults = UserDefaults.standard
    private let storageKey = "notified_notams"
    private let retentionDays = 7
    
    private var entries: [NotifiedNOTAMEntry] = []
    
    init() {
        load()
        cleanup()
    }
    
    // MARK: - Public API
    
    /// Check if a NOTAM has already been notified
    func hasBeenNotified(_ notamId: String) -> Bool {
        entries.contains { $0.notamId == notamId }
    }
    
    /// Mark a NOTAM as notified
    func markAsNotified(_ notamId: String) {
        guard !hasBeenNotified(notamId) else { return }
        
        let entry = NotifiedNOTAMEntry(notamId: notamId, notifiedDate: Date())
        entries.append(entry)
        save()
    }
    
    /// Remove entries older than retention period
    func cleanup() {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -retentionDays, to: Date()) ?? Date()
        let originalCount = entries.count
        
        entries.removeAll { $0.notifiedDate < cutoffDate }
        
        if entries.count != originalCount {
            save()
        }
    }
    
    // MARK: - Persistence
    
    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([NotifiedNOTAMEntry].self, from: data) else {
            return
        }
        entries = decoded
    }
    
    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
