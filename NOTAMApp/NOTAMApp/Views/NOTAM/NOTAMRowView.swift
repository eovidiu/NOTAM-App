import SwiftUI

struct NOTAMRowView: View {
    let notam: NOTAM

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // NOTAM ID badge
                Text(notam.displayId)
                    .font(.caption.monospaced().bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(typeColor.opacity(0.2))
                    .foregroundStyle(typeColor)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                // Type indicator
                Text(notam.type.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                // Severity indicator
                HStack(spacing: 4) {
                    Image(systemName: notam.severity.icon)
                        .foregroundStyle(notam.severity.color)
                    if notam.severity != .info {
                        Text(notam.severity.label)
                            .font(.caption2.bold())
                            .foregroundStyle(notam.severity.color)
                    }
                }
            }

            // Location
            HStack(spacing: 4) {
                Image(systemName: "mappin")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(notam.location)
                    .font(.subheadline)
            }

            // Summary text (first line of NOTAM)
            Text(summaryText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            // Effective period
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(notam.effectivePeriodDescription)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var typeColor: Color {
        switch notam.type {
        case .new: return .blue
        case .replacement: return .orange
        case .cancellation: return .red
        }
    }

    private var summaryText: String {
        let translator = NOTAMTranslator.shared
        return translator.translate(notam).summary
    }
}

#Preview {
    List {
        NOTAMRowView(notam: NOTAM(
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
            minimumFL: "000",
            maximumFL: "999",
            location: "LROP",
            effectiveStart: Date(),
            effectiveEnd: Date().addingTimeInterval(86400),
            isEstimatedEnd: false,
            isPermanent: false,
            text: "RWY 08R/26L CLSD DUE TO MAINT",
            coordinates: nil
        ))
    }
}
