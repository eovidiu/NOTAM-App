import SwiftUI
import CoreLocation

struct LocateFIRsView: View {
    @StateObject private var locationManager = LocationManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var nearbyFIRs: [FIRCoordinate] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var userLocation: CLLocation?

    private let settingsStore = SettingsStore.shared

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Nearby FIRs")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            notDeterminedView
        case .denied, .restricted:
            deniedView
        case .authorizedWhenInUse, .authorizedAlways:
            authorizedView
        @unknown default:
            notDeterminedView
        }
    }

    // MARK: - Permission States

    private var notDeterminedView: some View {
        ContentUnavailableView {
            Label("Location Access", systemImage: "location.circle")
        } description: {
            Text("Allow location access to find FIRs near you.")
        } actions: {
            Button {
                locationManager.requestLocation()
            } label: {
                Label("Locate Me", systemImage: "location.fill")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var deniedView: some View {
        ContentUnavailableView {
            Label("Location Access Denied", systemImage: "location.slash")
        } description: {
            Text("Location access is required to find nearby FIRs. Please enable it in Settings.")
        } actions: {
            Button {
                openAppSettings()
            } label: {
                Label("Open Settings", systemImage: "gear")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Authorized View

    @ViewBuilder
    private var authorizedView: some View {
        if locationManager.isLoading {
            loadingView(message: "Getting your location...")
        } else if isSearching {
            loadingView(message: "Searching for nearby FIRs...")
        } else if let error = locationManager.error {
            errorView(message: error.localizedDescription)
        } else if let error = searchError {
            errorView(message: error)
        } else if nearbyFIRs.isEmpty {
            if userLocation != nil {
                noResultsView
            } else {
                requestLocationView
            }
        } else {
            resultsListView
        }
    }

    private func loadingView(message: String) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(message)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Error", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button {
                retrySearch()
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var noResultsView: some View {
        ContentUnavailableView {
            Label("No FIRs Found", systemImage: "mappin.slash")
        } description: {
            Text("No Flight Information Regions found within search radius.")
        } actions: {
            Button {
                retrySearch()
            } label: {
                Label("Search Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
        }
    }

    private var requestLocationView: some View {
        ContentUnavailableView {
            Label("Find Nearby FIRs", systemImage: "location.magnifyingglass")
        } description: {
            Text("Tap the button below to find Flight Information Regions near your current location.")
        } actions: {
            Button {
                startLocationSearch()
            } label: {
                Label("Locate Me", systemImage: "location.fill")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Results List

    private var resultsListView: some View {
        List {
            Section {
                ForEach(nearbyFIRs) { firCoord in
                    Button {
                        addFIR(firCoord)
                    } label: {
                        FIRLocationRow(firCoordinate: firCoord, userLocation: userLocation)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                if let location = userLocation {
                    Text("Found \(nearbyFIRs.count) FIRs near \(formatCoordinate(location.coordinate))")
                } else {
                    Text("Found \(nearbyFIRs.count) FIRs")
                }
            } footer: {
                Text("Tap a FIR to add it to your list.")
            }
        }
    }

    // MARK: - Actions

    private func startLocationSearch() {
        locationManager.requestLocation()
        observeLocationChanges()
    }

    private func observeLocationChanges() {
        Task {
            // Wait briefly for location manager to get location
            try? await Task.sleep(for: .milliseconds(100))

            // Poll for location updates
            for _ in 0..<50 {
                if let location = locationManager.location {
                    await searchNearbyFIRs(location: location)
                    return
                }
                if locationManager.error != nil {
                    return
                }
                try? await Task.sleep(for: .milliseconds(200))
            }
        }
    }

    private func retrySearch() {
        searchError = nil
        startLocationSearch()
    }

    @MainActor
    private func searchNearbyFIRs(location: CLLocation) async {
        userLocation = location
        isSearching = true
        searchError = nil

        do {
            let results = try await FIRLocationService.shared.findNearbyFIRs(
                location: location,
                radiusKm: 500
            )
            nearbyFIRs = results
        } catch {
            searchError = error.localizedDescription
        }

        isSearching = false
    }

    private func addFIR(_ firCoord: FIRCoordinate) {
        let fir = FIR(icaoCode: firCoord.icao, displayName: firCoord.name)
        settingsStore.addFIR(fir)
        dismiss()
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }

    private func formatCoordinate(_ coordinate: CLLocationCoordinate2D) -> String {
        let latDirection = coordinate.latitude >= 0 ? "N" : "S"
        let lonDirection = coordinate.longitude >= 0 ? "E" : "W"
        return String(format: "%.2f%@ %.2f%@",
                      abs(coordinate.latitude), latDirection,
                      abs(coordinate.longitude), lonDirection)
    }
}

// MARK: - FIR Location Row

private struct FIRLocationRow: View {
    let firCoordinate: FIRCoordinate
    let userLocation: CLLocation?

    private var distance: Double? {
        guard let userLocation = userLocation else { return nil }
        return userLocation.distance(from: firCoordinate.location) / 1000 // Convert to km
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(firCoordinate.icao)
                    .font(.headline.monospaced())

                Text(firCoordinate.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(firCoordinate.country)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if let distance = distance {
                Text(formatDistance(distance))
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "plus.circle")
                .foregroundStyle(.blue)
                .font(.title2)
        }
        .contentShape(Rectangle())
    }

    private func formatDistance(_ km: Double) -> String {
        if km < 1 {
            return String(format: "%.0f m", km * 1000)
        } else if km < 10 {
            return String(format: "%.1f km", km)
        } else {
            return String(format: "%.0f km", km)
        }
    }
}

#Preview {
    LocateFIRsView()
}
