import Foundation

/// Manages local caching of NOTAMs using FileManager
actor NOTAMCache {
    static let shared = NOTAMCache()

    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("NOTAMCache", isDirectory: true)

        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Cache Operations

    func save(notams: [NOTAM], for fir: String) async throws {
        let entry = CacheEntry(notams: notams, timestamp: Date())
        let data = try JSONEncoder().encode(entry)
        let fileURL = cacheFileURL(for: fir)
        try data.write(to: fileURL)
    }

    func load(for fir: String) async throws -> CacheEntry? {
        let fileURL = cacheFileURL(for: fir)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(CacheEntry.self, from: data)
    }

    func loadAll() async throws -> [String: CacheEntry] {
        var result: [String: CacheEntry] = [:]

        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return result
        }

        for file in files where file.pathExtension == "json" {
            let fir = file.deletingPathExtension().lastPathComponent
            if let entry = try? await load(for: fir) {
                result[fir] = entry
            }
        }

        return result
    }

    func clear(for fir: String) async throws {
        let fileURL = cacheFileURL(for: fir)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    func clearAll() async throws {
        if fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager.removeItem(at: cacheDirectory)
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    func clearOldEntries(olderThan days: Int = 7) async throws {
        let threshold = Date().addingTimeInterval(-TimeInterval(days * 24 * 60 * 60))

        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }

        for file in files where file.pathExtension == "json" {
            let fir = file.deletingPathExtension().lastPathComponent
            if let entry = try? await load(for: fir), entry.timestamp < threshold {
                try? fileManager.removeItem(at: file)
            }
        }
    }

    // MARK: - Private

    private func cacheFileURL(for fir: String) -> URL {
        cacheDirectory.appendingPathComponent("\(fir).json")
    }
}

struct CacheEntry: Codable {
    let notams: [NOTAM]
    let timestamp: Date

    var age: TimeInterval {
        Date().timeIntervalSince(timestamp)
    }

    var isStale: Bool {
        age > 3600 * 24 // Consider stale after 24 hours
    }
}
