import SwiftUI

/// Aviation Glass Changes List View
/// Displays NOTAM changes with premium card styling matching cockpit display mockup
struct ChangesListView: View {
    @StateObject private var changeStore = ChangeStore.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedChange: NOTAMChange?
    @State private var hasAppeared = false

    /// Unread changes count
    private var unreadCount: Int {
        changeStore.changes.filter { !$0.isRead }.count
    }

    /// Group changes by relative date (TODAY, YESTERDAY, or formatted date)
    private var groupedChanges: [(date: String, changes: [NOTAMChange])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let grouped = Dictionary(grouping: changeStore.changes) { change -> String in
            let changeDay = calendar.startOfDay(for: change.detectedAt)
            if changeDay == today {
                return "TODAY"
            } else if changeDay == yesterday {
                return "YESTERDAY"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM yyyy"
                return formatter.string(from: change.detectedAt).uppercased()
            }
        }

        // Sort groups: TODAY first, then YESTERDAY, then by date descending
        return grouped
            .map { (date: $0.key, changes: $0.value.sorted { $0.detectedAt > $1.detectedAt }) }
            .sorted { lhs, rhs in
                if lhs.date == "TODAY" { return true }
                if rhs.date == "TODAY" { return false }
                if lhs.date == "YESTERDAY" { return true }
                if rhs.date == "YESTERDAY" { return false }
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
                        Button {
                            HapticManager.shared.buttonTap()
                            Task { await changeStore.markAllAsRead() }
                        } label: {
                            Text("Mark All Read")
                                .font(AviationFont.caption())
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
                // Unread count subtitle
                if unreadCount > 0 {
                    HStack {
                        Text("\(unreadCount) unread update\(unreadCount == 1 ? "" : "s")")
                            .font(AviationFont.bodySecondary())
                            .foregroundStyle(Color("TextSecondary"))
                        Spacer()
                    }
                    .padding(.horizontal, AviationTheme.Spacing.xs)
                }

                ForEach(groupedChanges, id: \.date) { group in
                    VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
                        // Date header (TODAY, YESTERDAY, etc.)
                        SimpleSectionHeader(title: group.date)

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
/// Premium card design matching cockpit display mockup with glow effects
struct ChangeRowView: View {
    let change: NOTAMChange
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    /// Format NOTAM ID as "A0234/24 - KJFK"
    private var formattedId: String {
        "\(change.notam.displayId) - \(change.notam.location)"
    }

    /// Format time as "08:30 AM" style
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: change.detectedAt)
    }

    var body: some View {
        HStack(spacing: AviationTheme.Spacing.md) {
            // Change type icon with colored glow
            ZStack {
                // Outer glow
                Circle()
                    .fill(changeColor.opacity(0.2))
                    .frame(width: 48, height: 48)
                    .blur(radius: reduceTransparency ? 0 : 4)

                // Inner circle
                Circle()
                    .fill(changeColor.opacity(0.25))
                    .frame(width: 40, height: 40)

                Image(systemName: change.changeType.iconName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(changeColor)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 6) {
                // Top row: Type label + Timestamp on right
                HStack {
                    Text(change.changeType.displayName.uppercased())
                        .font(AviationFont.label())
                        .foregroundStyle(changeColor)

                    Spacer()

                    // Timestamp on right side
                    Text(formattedTime)
                        .font(AviationFont.timestamp())
                        .foregroundStyle(Color("TextDisabled"))
                }

                // NOTAM ID row with unread indicator
                HStack(spacing: 6) {
                    Text(formattedId)
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

                // Summary text
                Text(change.summary)
                    .font(AviationFont.bodySecondary())
                    .foregroundStyle(Color("TextSecondary"))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(AviationTheme.Spacing.md)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium)
                .stroke(changeColor.opacity(0.3), lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            // Thick left indicator bar - colored by change type
            UnevenRoundedRectangle(
                topLeadingRadius: AviationTheme.CornerRadius.medium,
                bottomLeadingRadius: AviationTheme.CornerRadius.medium,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            )
            .fill(changeColor)
            .frame(width: 4)
        }
        // Glow shadow effect
        .shadow(
            color: reduceTransparency ? .clear : changeColor.opacity(0.3),
            radius: 12,
            x: 0,
            y: 4
        )
    }

    /// Card background with subtle colored tint
    @ViewBuilder
    private var cardBackground: some View {
        if reduceTransparency {
            Color("Graphite")
        } else {
            ZStack {
                Color("Graphite")
                // Subtle colored tint overlay
                LinearGradient(
                    colors: [
                        changeColor.opacity(0.08),
                        changeColor.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
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
