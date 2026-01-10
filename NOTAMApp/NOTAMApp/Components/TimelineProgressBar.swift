import SwiftUI

/// Aviation Glass Timeline Progress Bar Component
/// Visualizes NOTAM effective period with current time indicator
struct TimelineProgressBar: View {
    let startDate: Date
    let endDate: Date
    var currentDate: Date = Date()
    var height: CGFloat = 6

    private var progress: Double {
        let total = endDate.timeIntervalSince(startDate)
        guard total > 0 else { return 0 }

        let elapsed = currentDate.timeIntervalSince(startDate)
        return min(max(elapsed / total, 0), 1)
    }

    private var isActive: Bool {
        currentDate >= startDate && currentDate <= endDate
    }

    private var isPast: Bool {
        currentDate > endDate
    }

    private var isFuture: Bool {
        currentDate < startDate
    }

    private var progressColor: Color {
        if isPast {
            return Color("TextDisabled")
        } else if isActive {
            return Color("AuroraGreen")
        } else {
            return Color("ElectricCyan")
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color("SlateGlass"))

                // Progress Fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                progressColor.opacity(0.8),
                                progressColor
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)

                // Current Time Indicator (if active)
                if isActive {
                    Circle()
                        .fill(progressColor)
                        .frame(width: height + 4, height: height + 4)
                        .shadow(color: progressColor.opacity(0.5), radius: 4)
                        .offset(x: geometry.size.width * progress - (height + 4) / 2.0)
                }
            }
        }
        .frame(height: height)
    }
}

// MARK: - Timeline Card

/// Complete timeline card with dates and progress bar
struct TimelineCard: View {
    let startDate: Date
    let endDate: Date
    var currentDate: Date = Date()

    private var isActive: Bool {
        currentDate >= startDate && currentDate <= endDate
    }

    private var isPast: Bool {
        currentDate > endDate
    }

    private var statusText: String {
        if isPast {
            return "EXPIRED"
        } else if isActive {
            return "ACTIVE"
        } else {
            return "UPCOMING"
        }
    }

    private var statusColor: Color {
        if isPast {
            return Color("TextDisabled")
        } else if isActive {
            return Color("AuroraGreen")
        } else {
            return Color("ElectricCyan")
        }
    }

    private var timeRemaining: String {
        if isPast {
            return "Ended \(endDate.formatted(.relative(presentation: .named)))"
        } else if isActive {
            return "Ends \(endDate.formatted(.relative(presentation: .named)))"
        } else {
            return "Starts \(startDate.formatted(.relative(presentation: .named)))"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status Row
            HStack {
                // Status Badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)

                    Text(statusText)
                        .font(AviationFont.label())
                        .foregroundStyle(statusColor)
                }

                Spacer()

                // Time Remaining
                Text(timeRemaining)
                    .font(AviationFont.caption())
                    .foregroundStyle(Color("TextTertiary"))
            }

            // Progress Bar
            TimelineProgressBar(
                startDate: startDate,
                endDate: endDate,
                currentDate: currentDate,
                height: 4
            )

            // Date Labels
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("FROM")
                        .font(AviationFont.label())
                        .foregroundStyle(Color("TextDisabled"))

                    Text(startDate.formatted(date: .abbreviated, time: .shortened))
                        .font(AviationFont.timestamp())
                        .foregroundStyle(Color("TextSecondary"))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("TO")
                        .font(AviationFont.label())
                        .foregroundStyle(Color("TextDisabled"))

                    Text(endDate.formatted(date: .abbreviated, time: .shortened))
                        .font(AviationFont.timestamp())
                        .foregroundStyle(Color("TextSecondary"))
                }
            }
        }
        .padding(AviationTheme.Spacing.md)
        .background(Color("Graphite"))
        .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Compact Time Remaining

/// Compact time remaining indicator
struct TimeRemainingBadge: View {
    let endDate: Date
    var currentDate: Date = Date()

    private var isExpired: Bool {
        currentDate > endDate
    }

    private var timeText: String {
        if isExpired {
            return "Expired"
        }

        let interval = endDate.timeIntervalSince(currentDate)
        let hours = Int(interval / 3600)
        let days = hours / 24

        if days > 0 {
            return "\(days)d remaining"
        } else if hours > 0 {
            return "\(hours)h remaining"
        } else {
            let minutes = Int(interval / 60)
            return "\(max(minutes, 1))m remaining"
        }
    }

    private var color: Color {
        if isExpired {
            return Color("TextDisabled")
        }

        let hours = endDate.timeIntervalSince(currentDate) / 3600

        if hours < 2 {
            return Color("CrimsonPulse")
        } else if hours < 24 {
            return Color("AmberAlert")
        } else {
            return Color("AuroraGreen")
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isExpired ? "clock.badge.xmark" : "clock")
                .font(.system(size: 10, weight: .medium))

            Text(timeText)
                .font(AviationFont.caption())
        }
        .foregroundStyle(color)
    }
}

// MARK: - Preview

#Preview("Timeline Components") {
    ScrollView {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Progress Bar (Active)")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))

                TimelineProgressBar(
                    startDate: Date().addingTimeInterval(-86400),
                    endDate: Date().addingTimeInterval(86400)
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Progress Bar (Expired)")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))

                TimelineProgressBar(
                    startDate: Date().addingTimeInterval(-172800),
                    endDate: Date().addingTimeInterval(-86400)
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Timeline Card (Active)")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))

                TimelineCard(
                    startDate: Date().addingTimeInterval(-86400),
                    endDate: Date().addingTimeInterval(86400 * 3)
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Time Remaining Badges")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))

                HStack(spacing: 16) {
                    TimeRemainingBadge(endDate: Date().addingTimeInterval(3600))
                    TimeRemainingBadge(endDate: Date().addingTimeInterval(86400))
                    TimeRemainingBadge(endDate: Date().addingTimeInterval(-3600))
                }
            }
        }
        .padding()
    }
    .background(Color("DeepSpace"))
}
