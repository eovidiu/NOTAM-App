import SwiftUI

struct ChangeDetailView: View {
    let change: NOTAMChange

    @StateObject private var changeStore = ChangeStore.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Change type header
                changeHeader

                // Current NOTAM
                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        change.changeType == .expired ? "Expired NOTAM" : "Current NOTAM",
                        systemImage: "doc.text"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    NavigationLink(value: change.notam) {
                        notamCard(change.notam)
                    }
                    .buttonStyle(.plain)
                }

                // Previous NOTAM (for modifications)
                if let previous = change.previousNotam {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Previous Version", systemImage: "doc.text.below.ecg")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        notamCard(previous)
                            .opacity(0.7)
                    }

                    // Diff view
                    if change.changeType == .modified {
                        diffSection(previous: previous, current: change.notam)
                    }
                }

                // Details
                detailsSection
            }
            .padding()
        }
        .navigationTitle("Change Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: NOTAM.self) { notam in
            NOTAMDetailView(notam: notam)
        }
        .task {
            if !change.isRead {
                await changeStore.markAsRead(change)
            }
        }
    }

    private var changeHeader: some View {
        HStack {
            Image(systemName: change.changeType.iconName)
                .font(.largeTitle)
                .foregroundStyle(changeColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(change.changeType.displayName)
                    .font(.headline)

                Text(change.detailedDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(changeColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func notamCard(_ notam: NOTAM) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(notam.displayId)
                    .font(.headline.monospaced())

                Spacer()

                Text(notam.type.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }

            Text(notam.location)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(notam.text)
                .font(.caption.monospaced())
                .lineLimit(4)

            Text(notam.effectivePeriodDescription)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func diffSection(previous: NOTAM, current: NOTAM) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Changes", systemImage: "arrow.triangle.2.circlepath")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                if previous.text != current.text {
                    diffRow(label: "Text", old: previous.text, new: current.text)
                }

                if previous.effectiveStart != current.effectiveStart {
                    diffRow(
                        label: "Start Date",
                        old: formatDate(previous.effectiveStart),
                        new: formatDate(current.effectiveStart)
                    )
                }

                if previous.effectiveEnd != current.effectiveEnd {
                    diffRow(
                        label: "End Date",
                        old: previous.effectiveEnd.map { formatDate($0) } ?? "None",
                        new: current.effectiveEnd.map { formatDate($0) } ?? "None"
                    )
                }

                if previous.type != current.type {
                    diffRow(
                        label: "Type",
                        old: previous.type.displayName,
                        new: current.type.displayName
                    )
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func diffRow(label: String, old: String, new: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.bold())

            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading) {
                    Text("Before")
                        .font(.caption2)
                        .foregroundStyle(.red)
                    Text(old)
                        .font(.caption)
                        .strikethrough()
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading) {
                    Text("After")
                        .font(.caption2)
                        .foregroundStyle(.green)
                    Text(new)
                        .font(.caption)
                }
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Details", systemImage: "info.circle")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                detailRow(label: "Detected", value: formatDateTime(change.detectedAt))
                detailRow(label: "FIR", value: change.notam.affectedFIR)
                detailRow(label: "Location", value: change.notam.location)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .font(.caption)
    }

    private var changeColor: Color {
        switch change.changeType {
        case .new: return .green
        case .expired: return .gray
        case .modified: return .orange
        case .cancelled: return .red
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ChangeDetailView(change: NOTAMChange(
            changeType: .new,
            notam: NOTAM(
                id: "NOTAM_1",
                series: "A",
                number: "0123/24",
                type: .new,
                issued: Date(),
                affectedFIR: "LROP",
                selectionCode: nil,
                traffic: nil,
                purpose: nil,
                scope: nil,
                minimumFL: nil,
                maximumFL: nil,
                location: "LROP",
                effectiveStart: Date(),
                effectiveEnd: nil,
                isEstimatedEnd: false,
                isPermanent: false,
                text: "RWY 08R/26L CLSD",
                coordinates: nil
            )
        ))
    }
}
