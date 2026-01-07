import SwiftUI

struct ChangesListView: View {
    @StateObject private var changeStore = ChangeStore.shared
    @State private var selectedChange: NOTAMChange?

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
            .navigationTitle("Changes")
            .navigationDestination(for: NOTAMChange.self) { change in
                ChangeDetailView(change: change)
            }
            .toolbar {
                if !changeStore.changes.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                Task { await changeStore.markAllAsRead() }
                            } label: {
                                Label("Mark All Read", systemImage: "checkmark.circle")
                            }

                            Button(role: .destructive) {
                                Task { await changeStore.clearAll() }
                            } label: {
                                Label("Clear All", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }

    private var changesList: some View {
        List {
            ForEach(groupedChanges, id: \.date) { group in
                Section {
                    ForEach(group.changes) { change in
                        NavigationLink(value: change) {
                            ChangeRowView(change: change)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await changeStore.removeChange(change) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            if !change.isRead {
                                Button {
                                    Task { await changeStore.markAsRead(change) }
                                } label: {
                                    Label("Mark Read", systemImage: "checkmark.circle")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                } header: {
                    Text(group.date)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct ChangeRowView: View {
    let change: NOTAMChange

    var body: some View {
        HStack(spacing: 12) {
            // Change type icon
            Image(systemName: change.changeType.iconName)
                .font(.title2)
                .foregroundStyle(changeColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(change.notam.displayId)
                        .font(.subheadline.bold())

                    if !change.isRead {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                    }
                }

                Text(change.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text(change.detectedAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var changeColor: Color {
        switch change.changeType {
        case .new: return .green
        case .expired: return .gray
        case .modified: return .orange
        case .cancelled: return .red
        }
    }
}

#Preview {
    ChangesListView()
}
