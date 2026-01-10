import SwiftUI

/// Aviation Glass Change Detail View
/// Premium detail view for NOTAM changes with diff visualization
struct ChangeDetailView: View {
    let change: NOTAMChange

    @StateObject private var changeStore = ChangeStore.shared

    var body: some View {
        ZStack {
            // Background
            Color("DeepSpace")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AviationTheme.Spacing.md) {
                    // Change type header
                    changeHeader

                    // Current NOTAM
                    VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
                        SimpleSectionHeader(
                            title: change.changeType == .expired ? "EXPIRED NOTAM" : "CURRENT NOTAM"
                        )

                        NavigationLink(value: change.notam) {
                            notamCard(change.notam)
                        }
                        .buttonStyle(.plain)
                    }

                    // Previous NOTAM (for modifications)
                    if let previous = change.previousNotam {
                        VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
                            SimpleSectionHeader(title: "PREVIOUS VERSION")

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
                .padding(AviationTheme.Spacing.md)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Change Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("DeepSpace"), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
        HStack(spacing: AviationTheme.Spacing.md) {
            // Icon with glow
            ZStack {
                Circle()
                    .fill(changeColor.opacity(0.2))
                    .frame(width: 56, height: 56)

                Circle()
                    .fill(changeColor.opacity(0.1))
                    .frame(width: 72, height: 72)
                    .blur(radius: 8)

                Image(systemName: change.changeType.iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(changeColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(change.changeType.displayName)
                    .font(AviationFont.sectionHeader())
                    .foregroundStyle(Color("TextPrimary"))

                Text(change.detailedDescription)
                    .font(AviationFont.bodySecondary())
                    .foregroundStyle(Color("TextSecondary"))
            }

            Spacer()
        }
        .padding(AviationTheme.Spacing.md)
        .background(
            LinearGradient(
                colors: [
                    changeColor.opacity(0.15),
                    Color("Graphite")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.large)
                .stroke(changeColor.opacity(0.3), lineWidth: 1)
        )
    }

    private func notamCard(_ notam: NOTAM) -> some View {
        VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
            HStack {
                NOTAMIDBadge(id: notam.displayId, style: .standard)

                Spacer()

                Text(notam.type.displayName)
                    .font(AviationFont.label())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color("SlateGlass"))
                    .foregroundStyle(Color("TextSecondary"))
                    .clipShape(Capsule())
            }

            HStack(spacing: 6) {
                Image(systemName: "mappin")
                    .font(.system(size: 12))
                Text(notam.location)
                    .font(AviationFont.bodySecondary())
            }
            .foregroundStyle(Color("TextSecondary"))

            Text(notam.text)
                .font(AviationFont.rawText())
                .foregroundStyle(Color("TextPrimary"))
                .lineLimit(4)

            Text(notam.effectivePeriodDescription)
                .font(AviationFont.timestamp())
                .foregroundStyle(Color("TextDisabled"))
        }
        .padding(AviationTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("Graphite"))
        .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func diffSection(previous: NOTAM, current: NOTAM) -> some View {
        VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
            SimpleSectionHeader(title: "CHANGES")

            GlassCard {
                VStack(alignment: .leading, spacing: AviationTheme.Spacing.md) {
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
            }
        }
    }

    private func diffRow(label: String, old: String, new: String) -> some View {
        VStack(alignment: .leading, spacing: AviationTheme.Spacing.xs) {
            Text(label.uppercased())
                .font(AviationFont.label())
                .foregroundStyle(Color("TextTertiary"))

            HStack(alignment: .top, spacing: AviationTheme.Spacing.sm) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 10))
                        Text("Before")
                            .font(AviationFont.label())
                    }
                    .foregroundStyle(Color("CrimsonPulse"))

                    Text(old)
                        .font(AviationFont.bodySecondary())
                        .strikethrough()
                        .foregroundStyle(Color("TextDisabled"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color("TextDisabled"))

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 10))
                        Text("After")
                            .font(AviationFont.label())
                    }
                    .foregroundStyle(Color("AuroraGreen"))

                    Text(new)
                        .font(AviationFont.bodySecondary())
                        .foregroundStyle(Color("TextPrimary"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
            SimpleSectionHeader(title: "DETAILS")

            GlassCard {
                VStack(spacing: AviationTheme.Spacing.sm) {
                    detailRow(label: "Detected", value: formatDateTime(change.detectedAt))
                    Divider().background(Color.white.opacity(0.1))
                    detailRow(label: "FIR", value: change.notam.affectedFIR)
                    Divider().background(Color.white.opacity(0.1))
                    detailRow(label: "Location", value: change.notam.location)
                }
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AviationFont.bodySecondary())
                .foregroundStyle(Color("TextTertiary"))
            Spacer()
            Text(value)
                .font(AviationFont.bodyPrimary())
                .foregroundStyle(Color("TextPrimary"))
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
