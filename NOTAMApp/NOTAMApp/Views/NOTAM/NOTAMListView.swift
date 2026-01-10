import SwiftUI

/// Aviation Glass NOTAM List View
/// Main list with collapsible FIR sections and premium search
struct NOTAMListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var searchText = ""
    @State private var selectedNotam: NOTAM?
    @State private var showInactiveNotams = false
    @State private var hasAppeared = false

    // Persisted collapsed state (comma-separated FIR codes)
    @AppStorage("collapsedFIRs") private var collapsedFIRsString: String = ""

    private var collapsedFIRs: Set<String> {
        Set(collapsedFIRsString.split(separator: ",").map { String($0) })
    }

    private func isCollapsed(_ fir: String) -> Bool {
        collapsedFIRs.contains(fir)
    }

    private func toggleCollapsed(_ fir: String) {
        HapticManager.shared.light()
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
            ZStack {
                // Background
                Color("DeepSpace")
                    .ignoresSafeArea()

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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("DeepSpace"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: NOTAM.self) { notam in
                NOTAMDetailView(notam: notam)
            }
            .refreshable {
                HapticManager.shared.medium()
                await appState.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("NOTAMs")
                            .font(.headline)
                            .foregroundStyle(Color("TextPrimary"))
                        Text(headerSubtitle)
                            .font(AviationFont.caption())
                            .foregroundStyle(Color("TextSecondary"))
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    if appState.isLoading {
                        ProgressView()
                            .tint(Color("ElectricCyan"))
                    } else {
                        Button {
                            HapticManager.shared.buttonTap()
                            Task { await appState.refresh() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(Color("ElectricCyan"))
                        }
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    filterMenu
                }
            }
        }
    }

    private var filterMenu: some View {
        Menu {
            Button {
                showInactiveNotams = false
                HapticManager.shared.light()
            } label: {
                Label(
                    "Active Only (\(activeNotamsCount))",
                    systemImage: showInactiveNotams ? "" : "checkmark"
                )
            }

            Button {
                showInactiveNotams = true
                HapticManager.shared.light()
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
            // Pill badge showing count
            HStack(spacing: 4) {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                Text(showInactiveNotams ? "All" : "Active")
                    .font(AviationFont.label())
            }
            .foregroundStyle(Color("ElectricCyan"))
        }
    }

    /// Header subtitle showing active count (matches mockup "23 Active" style)
    private var headerSubtitle: String {
        let count = showInactiveNotams ? totalNotamsCount : activeNotamsCount
        return "\(count) Active"
    }

    private var notamList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Search Bar
                PremiumSearchBar(text: $searchText, placeholder: "Search NOTAMs...")
                    .padding(.horizontal, AviationTheme.Spacing.md)
                    .padding(.vertical, AviationTheme.Spacing.sm)

                // Last refresh info
                if let lastRefresh = appState.lastRefreshDate {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Updated")
                        Text(lastRefresh, style: .relative)
                        Text("ago")
                    }
                    .font(AviationFont.caption())
                    .foregroundStyle(Color("TextDisabled"))
                    .padding(.vertical, AviationTheme.Spacing.xs)
                }

                // FIR Sections
                ForEach(filteredNotamsByFIR, id: \.fir) { fir, notams in
                    VStack(spacing: 0) {
                        // Section Header
                        SectionHeader(
                            code: fir,
                            count: notams.count,
                            isExpanded: !isCollapsed(fir),
                            onToggle: { toggleCollapsed(fir) }
                        )
                        .background(Color("Obsidian"))

                        // NOTAM Cards with staggered animation
                        if !isCollapsed(fir) {
                            LazyVStack(spacing: AviationTheme.Spacing.sm) {
                                ForEach(Array(notams.enumerated()), id: \.element.id) { index, notam in
                                    NavigationLink(value: notam) {
                                        NOTAMRowView(notam: notam)
                                    }
                                    .buttonStyle(.plain)
                                    .opacity(hasAppeared ? 1 : 0)
                                    .offset(y: hasAppeared ? 0 : 20)
                                    .animation(
                                        reduceMotion ? nil : AviationAnimation.staggered(index: index),
                                        value: hasAppeared
                                    )
                                }
                            }
                            .padding(.horizontal, AviationTheme.Spacing.md)
                            .padding(.bottom, AviationTheme.Spacing.md)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("DeepSpace"))
        .animation(reduceMotion ? nil : AviationAnimation.standard, value: searchText)
        .animation(reduceMotion ? nil : AviationAnimation.standard, value: showInactiveNotams)
        .animation(reduceMotion ? nil : AviationAnimation.standard, value: collapsedFIRsString)
        .onAppear {
            // Trigger staggered reveal animation
            if !hasAppeared {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    hasAppeared = true
                }
            }
        }
    }
}

#Preview {
    NOTAMListView()
        .environmentObject(AppState())
}
