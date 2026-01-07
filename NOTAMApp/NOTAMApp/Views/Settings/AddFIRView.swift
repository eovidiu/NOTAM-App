import SwiftUI

struct AddFIRView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsStore = SettingsStore.shared

    @State private var icaoCode = ""
    @State private var displayName = ""
    @State private var showError = false
    @State private var errorMessage = ""

    private var isValidCode: Bool {
        FIR.isValidICAOCode(icaoCode)
    }

    private var isDuplicate: Bool {
        settingsStore.settings.configuredFIRs.contains { $0.icaoCode == icaoCode.uppercased() }
    }

    var body: some View {
        NavigationStack {
            Form {
                // Manual entry
                Section {
                    TextField("ICAO Code", text: $icaoCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(.headline.monospaced())
                        .onChange(of: icaoCode) { _, newValue in
                            // Limit to 4 characters and uppercase
                            icaoCode = String(newValue.prefix(4)).uppercased()
                        }

                    TextField("Display Name (Optional)", text: $displayName)
                } header: {
                    Text("Enter FIR Code")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        if !icaoCode.isEmpty {
                            if !isValidCode {
                                Label("ICAO code must be 4 letters", systemImage: "exclamationmark.circle")
                                    .foregroundStyle(.red)
                            } else if isDuplicate {
                                Label("This FIR is already configured", systemImage: "exclamationmark.circle")
                                    .foregroundStyle(.orange)
                            } else {
                                Label("Valid ICAO code", systemImage: "checkmark.circle")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    .font(.caption)
                }

                // Quick add from common FIRs
                Section {
                    ForEach(availableCommonFIRs) { fir in
                        Button {
                            addFIR(fir)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(fir.icaoCode)
                                        .font(.headline.monospaced())
                                    Text(fir.displayName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Quick Add")
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

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addCustomFIR()
                    }
                    .disabled(!isValidCode || isDuplicate)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var availableCommonFIRs: [FIR] {
        let configuredCodes = Set(settingsStore.settings.configuredFIRs.map { $0.icaoCode })
        return FIR.commonFIRs.filter { !configuredCodes.contains($0.icaoCode) }
    }

    private func addCustomFIR() {
        guard isValidCode && !isDuplicate else { return }

        let fir = FIR(
            icaoCode: icaoCode.uppercased(),
            displayName: displayName.isEmpty ? nil : displayName
        )

        settingsStore.addFIR(fir)
        dismiss()
    }

    private func addFIR(_ fir: FIR) {
        settingsStore.addFIR(fir)
        dismiss()
    }
}

#Preview {
    AddFIRView()
}
