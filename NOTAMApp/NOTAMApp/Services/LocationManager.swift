import Foundation
import CoreLocation

/// Error types for location operations
enum LocationError: LocalizedError {
    case permissionDenied
    case permissionRestricted
    case locationUnknown
    case locationUnavailable
    case timeout
    case underlying(Error)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied. Enable location access in Settings."
        case .permissionRestricted:
            return "Location access is restricted on this device."
        case .locationUnknown:
            return "Unable to determine location. Please try again."
        case .locationUnavailable:
            return "Location services are unavailable."
        case .timeout:
            return "Location request timed out. Please try again."
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}

/// Manages location services for finding nearby Flight Information Regions
@MainActor
final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    // MARK: - Published Properties
    
    @Published private(set) var location: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var isLoading = false
    @Published private(set) var error: LocationError?
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var timeoutTask: Task<Void, Never>?
    
    private static let locationTimeout: TimeInterval = 15.0
    
    // MARK: - Initialization
    
    override init() {
        self.authorizationStatus = CLLocationManager().authorizationStatus
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Public Methods
    
    /// Request location permission and get current location
    func requestLocation() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let location = try await fetchLocation()
                self.location = location
                self.error = nil
            } catch let locationError as LocationError {
                self.error = locationError
            } catch {
                self.error = .underlying(error)
            }
            self.isLoading = false
        }
    }
    
    /// Async version of location request
    func requestLocationAsync() async throws -> CLLocation {
        guard !isLoading else {
            throw LocationError.locationUnavailable
        }
        
        isLoading = true
        error = nil
        
        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }
        
        do {
            let location = try await fetchLocation()
            self.location = location
            self.error = nil
            return location
        } catch let locationError as LocationError {
            self.error = locationError
            throw locationError
        } catch {
            let wrappedError = LocationError.underlying(error)
            self.error = wrappedError
            throw wrappedError
        }
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() {
        authorizationStatus = locationManager.authorizationStatus
    }
    
    /// Whether location services are available and authorized
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    /// Whether permission has not been requested yet
    var canRequestPermission: Bool {
        authorizationStatus == .notDetermined
    }
    
    // MARK: - Private Methods
    
    private func fetchLocation() async throws -> CLLocation {
        // Check if location services are enabled
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.locationUnavailable
        }
        
        // Handle authorization status
        switch authorizationStatus {
        case .notDetermined:
            return try await requestPermissionAndLocation()
        case .restricted:
            throw LocationError.permissionRestricted
        case .denied:
            throw LocationError.permissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            return try await performLocationRequest()
        @unknown default:
            throw LocationError.locationUnavailable
        }
    }
    
    private func requestPermissionAndLocation() async throws -> CLLocation {
        // Request permission
        locationManager.requestWhenInUseAuthorization()
        
        // Wait for authorization response
        try await waitForAuthorization()
        
        // Check new status
        if isAuthorized {
            return try await performLocationRequest()
        } else {
            throw LocationError.permissionDenied
        }
    }
    
    private func waitForAuthorization() async throws {
        // Wait up to 30 seconds for user to respond to permission dialog
        let maxWait: TimeInterval = 30.0
        let checkInterval: TimeInterval = 0.5
        var elapsed: TimeInterval = 0
        
        while authorizationStatus == .notDetermined && elapsed < maxWait {
            try await Task.sleep(nanoseconds: UInt64(checkInterval * 1_000_000_000))
            elapsed += checkInterval
            checkAuthorizationStatus()
        }
    }
    
    private func performLocationRequest() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            
            // Start timeout timer
            self.timeoutTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(Self.locationTimeout * 1_000_000_000))
                if self.locationContinuation != nil {
                    self.locationContinuation?.resume(throwing: LocationError.timeout)
                    self.locationContinuation = nil
                    self.locationManager.stopUpdatingLocation()
                }
            }
            
            // Request single location
            self.locationManager.requestLocation()
        }
    }
    
    private func completeLocationRequest(with result: Result<CLLocation, Error>) {
        timeoutTask?.cancel()
        timeoutTask = nil
        
        guard let continuation = locationContinuation else { return }
        locationContinuation = nil
        
        switch result {
        case .success(let location):
            continuation.resume(returning: location)
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.completeLocationRequest(with: .success(location))
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            let locationError: LocationError
            
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    locationError = .permissionDenied
                case .locationUnknown:
                    locationError = .locationUnknown
                case .network:
                    locationError = .locationUnavailable
                default:
                    locationError = .underlying(error)
                }
            } else {
                locationError = .underlying(error)
            }
            
            self.completeLocationRequest(with: .failure(locationError))
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}
