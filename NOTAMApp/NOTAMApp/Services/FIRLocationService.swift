import Foundation
import CoreLocation

// MARK: - Models

/// Represents a FIR with geographic coordinates for location-based lookup
struct FIRCoordinate: Codable, Identifiable, Hashable {
    let icao: String
    let lat: Double
    let lon: Double
    let name: String
    let country: String
    
    var id: String { icao }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var location: CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }
}

/// Container for FIR coordinates JSON file
struct FIRCoordinatesData: Codable {
    let schemaVersion: String
    let description: String
    let firs: [FIRCoordinate]
}

// MARK: - Service

/// Service for finding nearby FIRs based on geographic coordinates
final class FIRLocationService {
    static let shared = FIRLocationService()
    
    private var firs: [FIRCoordinate] = []
    private var isLoaded = false
    
    private init() {
        loadFIRs()
    }
    
    // MARK: - Loading
    
    private func loadFIRs() {
        guard let url = Bundle.main.url(forResource: "fir_coordinates", withExtension: "json") else {
            print("FIRLocationService: fir_coordinates.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let firData = try decoder.decode(FIRCoordinatesData.self, from: data)
            firs = firData.firs
            isLoaded = true
            print("FIRLocationService: Loaded \(firs.count) FIR coordinates")
        } catch {
            print("FIRLocationService: Failed to load FIR coordinates: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Location Search
    
    /// Finds FIRs near a given location within specified radius
    /// - Parameters:
    ///   - location: The reference location to search from
    ///   - radiusKm: Search radius in kilometers (default: 500km)
    /// - Returns: Array of nearby FIRs sorted by distance (closest first).
    ///            If no FIRs are within the radius, returns the 3 closest FIRs.
    func findNearbyFIRs(location: CLLocation, radiusKm: Double = 500) -> [FIRCoordinate] {
        guard !firs.isEmpty else { return [] }
        
        let radiusMeters = radiusKm * 1000
        
        // Calculate distance from each FIR and sort by distance
        let firsWithDistance: [(fir: FIRCoordinate, distance: CLLocationDistance)] = firs.map { fir in
            let distance = location.distance(from: fir.location)
            return (fir, distance)
        }
        .sorted { $0.distance < $1.distance }
        
        // Filter FIRs within radius
        let nearbyFIRs = firsWithDistance.filter { $0.distance <= radiusMeters }
        
        if nearbyFIRs.isEmpty {
            // No FIRs within radius - return closest 3
            return Array(firsWithDistance.prefix(3).map { $0.fir })
        }
        
        return nearbyFIRs.map { $0.fir }
    }
    
    /// Finds the single closest FIR to a given location
    /// - Parameter location: The reference location
    /// - Returns: The closest FIR, or nil if no FIRs are loaded
    func findClosestFIR(location: CLLocation) -> FIRCoordinate? {
        guard !firs.isEmpty else { return nil }
        
        return firs.min { fir1, fir2 in
            location.distance(from: fir1.location) < location.distance(from: fir2.location)
        }
    }
    
    /// Calculates distance in kilometers between a location and a FIR
    /// - Parameters:
    ///   - location: The reference location
    ///   - fir: The FIR to measure distance to
    /// - Returns: Distance in kilometers
    func distance(from location: CLLocation, to fir: FIRCoordinate) -> Double {
        location.distance(from: fir.location) / 1000.0
    }
    
    // MARK: - Direct Access
    
    /// Returns FIR by exact ICAO code
    func fir(byICAO icao: String) -> FIRCoordinate? {
        firs.first { $0.icao == icao.uppercased() }
    }
    
    /// Returns all loaded FIR coordinates
    var allFIRs: [FIRCoordinate] {
        firs
    }
}
