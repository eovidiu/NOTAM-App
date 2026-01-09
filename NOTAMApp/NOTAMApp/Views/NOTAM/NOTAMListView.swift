import SwiftUI

struct NOTAMListView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedNotam: NOTAM?
    @State private var showInactiveNotams = false

    // Persisted collapsed state (comma-separated FIR codes)
    @AppStorage("collapsedFIRs") private var collapsedFIRsString: String = ""

    private var collapsedFIRs: Set<String> {
        Set(collapsedFIRsString.split(separator: ",").map { String($0) })
    }

    private func isCollapsed(_ fir: String) -> Bool {
        collapsedFIRs.contains(fir)
    }

    private func toggleCollapsed(_ fir: String) {
        var current = collapsedFIRs
        if current.contains(fir) {
            current.remove(fir)
        } else {
            current.insert(fir)
        }
        collapsedFIRsString = current.sorted().joined(separator: ",")
    }

    var filteredNotamsByFIR: [(fir: String, notams: [NOTAM])] {
        return appState.notamsByFIR.compactMap { fir, notams in
            var filtered = notams

            // Filter by active status (default: show only active)
            if !showInactiveNotams {
                filtered = filtered.filter { $0.isActive }
            }

            // Filter by search text
            if !searchText.isEmpty {
                filtered = filtered.filter { notam in
                    notam.text.localizedCaseInsensitiveContains(searchText) ||
                    notam.displayId.localizedCaseInsensitiveContains(searchText) ||
                    notam.location.localizedCaseInsensitiveContains(searchText)
                }
            }

            return filtered.isEmpty ? nil : (fir, filtered)
        }
    }

    private var totalNotamsCount: Int {
        appState.notamsByFIR.reduce(0) { $0 + $1.notams.count }
    }

    private var activeNotamsCount: Int {
        appState.notamsByFIR.reduce(0) { total, group in
            total + group.notams.filter { $0.isActive }.count
        }
    }

    private var inactiveNotamsCount: Int {
        totalNotamsCount - activeNotamsCount
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

                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            showInactiveNotams = false
                        } label: {
                            Label(
                                "Active Only (\(activeNotamsCount))",
                                systemImage: showInactiveNotams ? "" : "checkmark"
                            )
                        }

                        Button {
                            showInactiveNotams = true
                        } label: {
                            Label(
                                "All NOTAMs (\(totalNotamsCount))",
                                systemImage: showInactiveNotams ? "checkmark" : ""
                            )
                        }

                        if inactiveNotamsCount > 0 {
                            Divider()
                            Text("\(inactiveNotamsCount) expired/future")
                                .font(.caption)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: showInactiveNotams ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                            if !showInactiveNotams {
                                Text("Active")
                                    .font(.caption)
                            }
                        }
                    }
                }

            }
        }
    }

    private var notamList: some View {
        List {
            if let lastRefresh = appState.lastRefreshDate {
                Section {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Updated")
                        Text(lastRefresh, style: .relative)
                        Text("ago")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                }
            }

            ForEach(filteredNotamsByFIR, id: \.fir) { fir, notams in
                Section {
                    if !isCollapsed(fir) {
                        ForEach(notams) { notam in
                            NavigationLink(value: notam) {
                                NOTAMRowView(notam: notam)
                            }
                        }
                    }
                } header: {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            toggleCollapsed(fir)
                        }
                    } label: {
                        HStack {
                            Image(systemName: isCollapsed(fir) ? "chevron.right" : "chevron.down")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                                .frame(width: 16)
                            Text(fir)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(notams.count) NOTAM\(notams.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: searchText)
        .animation(.default, value: showInactiveNotams)
        .animation(.default, value: collapsedFIRsString)
    }
}

#Preview {
    NOTAMListView()
        .environmentObject(AppState())
}
