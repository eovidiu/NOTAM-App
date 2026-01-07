import SwiftUI

struct AddFIRView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsStore = SettingsStore.shared

    @State private var searchText = ""
    @State private var displayName = ""
    @State private var showManualEntry = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let firService = ATSUnitService.shared

    private var searchResults: [ATSUnit] {
        guard !searchText.isEmpty else { return [] }
        return firService.search(searchText)
            .filter { unit in
                !settingsStore.settings.configuredFIRs.contains { $0.icaoCode == unit.icao }
            }
    }

    private var isValidCode: Bool {
        FIR.isValidICAOCode(searchText)
    }

    private var isDuplicate: Bool {
        settingsStore.settings.configuredFIRs.contains { $0.icaoCode == searchText.uppercased() }
    }

    private var canAddManually: Bool {
        isValidCode && !isDuplicate && searchResults.isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                // Search section
                Section {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search ICAO, name, or country...", text: $searchText)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                    }
                } footer: {
                    if !searchText.isEmpty && searchResults.isEmpty && !isValidCode {
                        Text("Enter at least 2 characters to search")
                            .foregroundStyle(.secondary)
                    }
                }

                // Search results
                if !searchResults.isEmpty {
                    Section {
                        ForEach(searchResults.prefix(15)) { unit in
                            Button {
                                addUnit(unit)
                            } label: {
                                FIRRow(unit: unit)
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text("Search Results (\(searchResults.count))")
                    }
                }

                // Manual entry option
                if canAddManually {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Code not in database", systemImage: "questionmark.circle")
                                    .foregroundStyle(.orange)
                                Spacer()
                            }

                            TextField("Display Name (Optional)", text: $displayName)

                            Button {
                                addCustomFIR()
                            } label: {
                                HStack {
                                    Text("Add \(searchText.uppercased())")
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } header: {
                        Text("Manual Entry")
                    } footer: {
                        Text("This ICAO code isn't in our database. You can still add it manually.")
                    }
                }

                // Show duplicate warning
                if isDuplicate && isValidCode {
                    Section {
                        Label("This FIR is already configured", systemImage: "exclamationmark.circle")
                            .foregroundStyle(.orange)
                    }
                }

                // Toggle for manual entry mode
                if searchText.isEmpty {
                    Section {
                        DisclosureGroup("Enter code manually", isExpanded: $showManualEntry) {
                            TextField("ICAO Code (4 letters)", text: $searchText)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .font(.headline.monospaced())
                                .onChange(of: searchText) { _, newValue in
                                    searchText = String(newValue.prefix(4)).uppercased()
                                }

                            TextField("Display Name (Optional)", text: $displayName)
                        }
                    } footer: {
                        Text("Use this if you know the exact ICAO code")
                    }
                }
            }
            .navigationTitle("Add FIR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func addUnit(_ unit: ATSUnit) {
        let fir = unit.toFIR()
        settingsStore.addFIR(fir)
        dismiss()
    }

    private func addCustomFIR() {
        guard isValidCode && !isDuplicate else { return }

        let fir = FIR(
            icaoCode: searchText.uppercased(),
            displayName: displayName.isEmpty ? nil : displayName
        )

        settingsStore.addFIR(fir)
        dismiss()
    }
}

// MARK: - FIR Row

private struct FIRRow: View {
    let unit: ATSUnit

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(unit.icao)
                    .font(.headline.monospaced())

                Text(unit.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(unit.country)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "plus.circle")
                .foregroundStyle(.blue)
                .font(.title2)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    AddFIRView()
}
