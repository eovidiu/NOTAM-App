import SwiftUI

/// Aviation Glass NOTAM Row View
/// Premium card design with severity indicators and time remaining
struct NOTAMRowView: View {
    let notam: NOTAM

    var body: some View {
        VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
            // Top Row: ID Badge + Type + Severity
            HStack(alignment: .center, spacing: AviationTheme.Spacing.sm) {
                // NOTAM ID Badge
                NOTAMIDBadge(id: notam.displayId, style: .compact)

                // Type indicator
                Text(notam.type.displayName)
                    .font(AviationFont.label())
                    .foregroundStyle(Color("TextTertiary"))

                Spacer()

                // Severity Badge
                SeverityBadge(severity: notam.severity, style: .standard)
            }

            // Location Row
            HStack(spacing: 6) {
                Image(systemName: "mappin")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color("TextTertiary"))

                Text(notam.location)
                    .font(AviationFont.bodyPrimary())
                    .foregroundStyle(Color("TextPrimary"))
            }

            // Summary text
            Text(summaryText)
                .font(AviationFont.bodySecondary())
                .foregroundStyle(Color("TextSecondary"))
                .lineLimit(2)

            // Bottom Row: Time remaining + effective period
            HStack {
                TimeRemainingBadge(
                    endDate: notam.effectiveEnd ?? Date.distantFuture,
                    currentDate: Date()
                )

                Spacer()

                // Effective period
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                    Text(notam.effectivePeriodDescription)
                        .font(AviationFont.timestamp())
                }
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
    }

    private var summaryText: String {
        let translator = NOTAMTranslator.shared
        return translator.translate(notam).summary
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            NOTAMRowView(notam: NOTAM(
                id: "NOTAM_1",
                series: "A",
                number: "0123/24",
                type: .new,
                issued: Date(),
                affectedFIR: "LROP",
                selectionCode: "QMRLC",
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

            NOTAMRowView(notam: NOTAM(
                id: "NOTAM_2",
                series: "A",
                number: "0456/24",
                type: .replacement,
                issued: Date(),
                affectedFIR: "KJFK",
                selectionCode: "QAFXX",
                traffic: nil,
                purpose: nil,
                scope: nil,
                minimumFL: "000",
                maximumFL: "999",
                location: "KJFK",
                effectiveStart: Date(),
                effectiveEnd: nil,
                isEstimatedEnd: false,
                isPermanent: true,
                text: "AIRSPACE CLOSED DUE TO SECURITY",
                coordinates: nil
            ))
        }
        .padding()
    }
    .background(Color("DeepSpace"))
}
