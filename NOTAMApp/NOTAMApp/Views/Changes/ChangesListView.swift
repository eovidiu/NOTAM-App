import SwiftUI

/// Aviation Glass Changes List View
/// Displays NOTAM changes with premium card styling
struct ChangesListView: View {
    @StateObject private var changeStore = ChangeStore.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedChange: NOTAMChange?
    @State private var hasAppeared = false

    private var groupedChanges: [(date: String, changes: [NOTAMChange])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let grouped = Dictionary(grouping: changeStore.changes) { change in
            formatter.string(from: change.detectedAt)
        }

        return grouped
            .map { (date: $0.key, changes: $0.value.sorted { $0.detectedAt > $1.detectedAt }) }
            .sorted { lhs, rhs in
                guard let lhsDate = lhs.changes.first?.detectedAt,
                      let rhsDate = rhs.changes.first?.detectedAt else {
                    return false
                }
                return lhsDate > rhsDate
            }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color("DeepSpace")
                    .ignoresSafeArea()

                Group {
                    if changeStore.changes.isEmpty {
                        EmptyStateView(
                            title: "No Changes",
                            message: "Changes to NOTAMs will appear here when detected during background refresh.",
                            systemImage: "bell.slash",
                            action: nil,
                            actionTitle: nil
                        )
                    } else {
                        changesList
                    }
                }
            }
            .navigationTitle("Changes")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("DeepSpace"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: NOTAMChange.self) { change in
                ChangeDetailView(change: change)
            }
            .toolbar {
                if !changeStore.changes.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                HapticManager.shared.buttonTap()
                                Task { await changeStore.markAllAsRead() }
                            } label: {
                                Label("Mark All Read", systemImage: "checkmark.circle")
                            }

                            Button(role: .destructive) {
                                HapticManager.shared.buttonTap()
                                Task { await changeStore.clearAll() }
                            } label: {
                                Label("Clear All", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(Color("ElectricCyan"))
                        }
                    }
                }
            }
        }
    }

    private var changesList: some View {
        ScrollView {
            LazyVStack(spacing: AviationTheme.Spacing.md) {
                ForEach(groupedChanges, id: \.date) { group in
                    VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
                        // Date header
                        SimpleSectionHeader(title: group.date.uppercased())

                        // Change cards with staggered animation
                        ForEach(Array(group.changes.enumerated()), id: \.element.id) { index, change in
                            NavigationLink(value: change) {
                                ChangeRowView(change: change)
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
                }
            }
            .padding(AviationTheme.Spacing.md)
        }
        .scrollContentBackground(.hidden)
        .background(Color("DeepSpace"))
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

/// Aviation Glass Change Row View
/// Premium card design for change items with type-specific styling
struct ChangeRowView: View {
    let change: NOTAMChange

    var body: some View {
        HStack(spacing: AviationTheme.Spacing.md) {
            // Change type icon with colored glow
            ZStack {
                Circle()
                    .fill(changeColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: change.changeType.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(changeColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                // Type label
                Text(change.changeType.displayName.uppercased())
                    .font(AviationFont.timestamp())
                    .foregroundStyle(changeColor)

                HStack {
                    Text(change.notam.displayId)
                        .font(AviationFont.cardTitle())
                        .foregroundStyle(Color("TextPrimary"))

                    if !change.isRead {
                        Circle()
                            .fill(Color("ElectricCyan"))
                            .frame(width: 8, height: 8)
                    }

                    Spacer()

                    // Chevron indicator
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color("TextDisabled"))
                }

                Text(change.summary)
                    .font(AviationFont.bodySecondary())
                    .foregroundStyle(Color("TextSecondary"))
                    .lineLimit(2)

                Text(change.detectedAt, style: .time)
                    .font(AviationFont.timestamp())
                    .foregroundStyle(Color("TextDisabled"))
            }
        }
        .padding(AviationTheme.Spacing.md)
        .background(Color("Graphite"))
        .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .overlay(
            // Left indicator bar - colored by change type
            RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium)
                .fill(Color.clear)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(changeColor)
                        .frame(width: 3)
                        .padding(.vertical, 8)
                }
        )
    }

    private var changeColor: Color {
        switch change.changeType {
        case .new: return Color("AuroraGreen")
        case .expired: return Color("TextDisabled")
        case .modified: return Color("AmberAlert")
        case .cancelled: return Color("CrimsonPulse")
        }
    }
}

#Preview {
    ChangesListView()
}
