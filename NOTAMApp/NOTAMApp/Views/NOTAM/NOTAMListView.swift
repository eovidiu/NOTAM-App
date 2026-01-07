import SwiftUI

struct NOTAMListView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedNotam: NOTAM?

    var filteredNotamsByFIR: [(fir: String, notams: [NOTAM])] {
        if searchText.isEmpty {
            return appState.notamsByFIR
        }

        return appState.notamsByFIR.compactMap { fir, notams in
            let filtered = notams.filter { notam in
                notam.text.localizedCaseInsensitiveContains(searchText) ||
                notam.displayId.localizedCaseInsensitiveContains(searchText) ||
                notam.location.localizedCaseInsensitiveContains(searchText)
            }
            return filtered.isEmpty ? nil : (fir, filtered)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if appState.isLoading && !appState.hasNotams {
                    LoadingView(message: "Fetching NOTAMs...")
                } else if let error = appState.error, !appState.hasNotams {
                    ErrorView(error: error) {
                        Task { await appState.refresh() }
                    }
                } else if !appState.hasNotams {
                    EmptyStateView(
                        title: "No NOTAMs",
                        message: "Pull to refresh or check your FIR configuration in Settings.",
                        systemImage: "doc.text",
                        action: {
                            Task { await appState.refresh() }
                        },
                        actionTitle: "Refresh"
                    )
                } else {
                    notamList
                }
            }
            .navigationTitle("NOTAMs")
            .navigationDestination(for: NOTAM.self) { notam in
                NOTAMDetailView(notam: notam)
            }
            .refreshable {
                await appState.refresh()
            }
            .searchable(text: $searchText, prompt: "Search NOTAMs")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if appState.isLoading {
                        ProgressView()
                    } else {
                        Button {
                            Task { await appState.refresh() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }

                ToolbarItem(placement: .status) {
                    if let date = appState.lastRefreshDate {
                        Text("Updated \(date, style: .relative) ago")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var notamList: some View {
        List {
            ForEach(filteredNotamsByFIR, id: \.fir) { fir, notams in
                Section {
                    ForEach(notams) { notam in
                        NavigationLink(value: notam) {
                            NOTAMRowView(notam: notam)
                        }
                    }
                } header: {
                    HStack {
                        Text(fir)
                            .font(.headline)
                        Spacer()
                        Text("\(notams.count) NOTAM\(notams.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: searchText)
    }
}

#Preview {
    NOTAMListView()
        .environmentObject(AppState())
}
