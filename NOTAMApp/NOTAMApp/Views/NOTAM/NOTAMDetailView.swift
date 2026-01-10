import SwiftUI

/// Aviation Glass NOTAM Detail View
/// Premium detail view with glass cards and timeline visualization
struct NOTAMDetailView: View {
    let notam: NOTAM

    @State private var selectedTab: DetailTab = .translated
    @State private var showShareSheet = false
    @State private var translated: TranslatedNOTAM?
    @State private var isLoadingAI = false

    private let translator = NOTAMTranslator.shared

    var body: some View {
        ZStack {
            // Background
            Color("DeepSpace")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Tab picker with custom styling
                Picker("View", selection: $selectedTab) {
                    ForEach(DetailTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(AviationTheme.Spacing.md)

                // Content
                ScrollView {
                    switch selectedTab {
                    case .translated:
                        translatedView
                    case .original:
                        originalView
                    }
                }
            }
        }
        .navigationTitle(notam.displayId)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("DeepSpace"), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color("ElectricCyan"))
                }
            }
        }
        .task {
            // Start with dictionary translation immediately
            translated = translator.translate(notam)

            // Then fetch AI translation in background if available (iOS 26+)
            if #available(iOS 26.0, *), translator.isAIAvailable {
                isLoadingAI = true
                translated = await translator.translateWithAI(notam)
                isLoadingAI = false
            }
        }
    }

    // MARK: - Translated View

    private var translatedView: some View {
        VStack(alignment: .leading, spacing: AviationTheme.Spacing.md) {
            if let translated {
                // Hero Header with NOTAM ID
                heroHeader

                // Status card with severity
                statusCard

                // Timeline card
                TimelineCard(
                    startDate: notam.effectiveStart,
                    endDate: notam.effectiveEnd ?? Date.distantFuture,
                    currentDate: Date()
                )

                // Sections (filter out redundant ones already shown elsewhere)
                ForEach(translated.sections.filter { section in
                    section.title != "Type" &&
                    section.title != "Location" &&
                    section.title != "Summary" &&
                    section.title != "Effective Period" &&
                    section.title != "Coordinates"
                }) { section in
                    sectionCard(section)
                }

                // Plain English text
                GlassCard {
                    VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
                        HStack {
                            Label("Plain English", systemImage: "text.bubble")
                                .font(AviationFont.label())
                                .foregroundStyle(Color("TextTertiary"))

                            Spacer()

                            if isLoadingAI {
                                HStack(spacing: 4) {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .tint(Color("ElectricCyan"))
                                    Text("AI translating...")
                                        .font(AviationFont.caption())
                                }
                                .foregroundStyle(Color("TextTertiary"))
                            } else if translated.aiPlainText != nil {
                                HStack(spacing: 4) {
                                    Image(systemName: "apple.intelligence")
                                    Text("AI")
                                }
                                .font(AviationFont.caption())
                                .foregroundStyle(Color("AzureNebula"))
                            }
                        }

                        Text(translated.bestTranslation)
                            .font(AviationFont.bodyPrimary())
                            .foregroundStyle(Color("TextSecondary"))
                    }
                }
            } else {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tint(Color("ElectricCyan"))
            }
        }
        .padding(AviationTheme.Spacing.md)
    }

    /// Full location name from ATSUnitService (e.g., "Bucharest Henri Coanda")
    private var locationFullName: String? {
        ATSUnitService.shared.unit(byICAO: notam.location)?.name
    }

    /// Formatted location string (e.g., "LROP - Bucharest Henri Coanda")
    private var formattedLocation: String {
        if let fullName = locationFullName {
            return "\(notam.location) - \(fullName)"
        }
        return notam.location
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
            HStack {
                NOTAMIDBadge(id: notam.displayId, style: .hero)
                Spacer()
                SeverityBadge(severity: notam.severity, style: .expanded)
            }

            // Location with full name
            HStack(spacing: 6) {
                Image(systemName: "mappin")
                    .font(.system(size: 14, weight: .medium))
                Text(formattedLocation)
                    .font(AviationFont.bodyPrimary())
            }
            .foregroundStyle(Color("TextSecondary"))

            // Coordinates (if available)
            if let coords = notam.coordinates {
                HStack(spacing: 6) {
                    Image(systemName: "location")
                        .font(.system(size: 12, weight: .medium))
                    Text(formatCoordinates(coords))
                        .font(AviationFont.caption())
                }
                .foregroundStyle(Color("TextDisabled"))
            }
        }
        .padding(AviationTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    notam.severity.themeColor.opacity(0.2),
                    Color("DeepSpace")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.large)
                .stroke(notam.severity.themeColor.opacity(0.3), lineWidth: 1)
        )
    }

    private func formatCoordinates(_ coords: Coordinates) -> String {
        let latDir = coords.latitude >= 0 ? "N" : "S"
        let lonDir = coords.longitude >= 0 ? "E" : "W"
        let lat = abs(coords.latitude)
        let lon = abs(coords.longitude)
        return String(format: "%.4f°%@, %.4f°%@", lat, latDir, lon, lonDir)
    }

    private var statusCard: some View {
        GlassCard {
            VStack(spacing: AviationTheme.Spacing.sm) {
                // Severity banner for critical/warning NOTAMs
                if notam.severity == .critical || notam.severity == .warning {
                    HStack {
                        Image(systemName: notam.severity.icon)
                        Text(notam.severity.label.uppercased())
                            .font(AviationFont.label())
                        Spacer()
                        Text(severityDescription)
                            .font(AviationFont.caption())
                    }
                    .foregroundStyle(.white)
                    .padding(AviationTheme.Spacing.sm)
                    .background(notam.severity.themeColor)
                    .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.small))
                }

                HStack {
                    // Severity indicator
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SEVERITY")
                            .font(AviationFont.label())
                            .foregroundStyle(Color("TextDisabled"))
                        HStack(spacing: 4) {
                            SeverityDot(severity: notam.severity)
                            Text(notam.severity.label)
                                .font(AviationFont.cardTitle())
                                .foregroundStyle(notam.severity.themeColor)
                        }
                    }

                    Spacer()

                    // Active status
                    VStack(alignment: .center, spacing: 4) {
                        Text("STATUS")
                            .font(AviationFont.label())
                            .foregroundStyle(Color("TextDisabled"))
                        HStack {
                            Circle()
                                .fill(notam.isActive ? Color("AuroraGreen") : Color("TextDisabled"))
                                .frame(width: 8, height: 8)
                            Text(notam.isActive ? "Active" : "Inactive")
                                .font(AviationFont.cardTitle())
                                .foregroundStyle(Color("TextPrimary"))
                        }
                    }

                    Spacer()

                    // Type
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("TYPE")
                            .font(AviationFont.label())
                            .foregroundStyle(Color("TextDisabled"))
                        Text(notam.type.displayName)
                            .font(AviationFont.cardTitle())
                            .foregroundStyle(typeColor)
                    }
                }
            }
        }
    }

    private var severityDescription: String {
        switch notam.severity {
        case .critical:
            return "Major operational impact"
        case .warning:
            return "Significant restriction"
        case .caution:
            return "Exercise caution"
        case .info:
            return "Informational"
        }
    }

    private func sectionCard(_ section: NOTAMSection) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
                Label(section.title, systemImage: section.icon)
                    .font(AviationFont.label())
                    .foregroundStyle(Color("TextTertiary"))

                Text(section.content)
                    .font(AviationFont.bodyPrimary())
                    .foregroundStyle(Color("TextSecondary"))
            }
        }
    }

    // MARK: - Original View

    private var originalView: some View {
        VStack(alignment: .leading, spacing: AviationTheme.Spacing.md) {
            // Header info
            GlassCard {
                VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
                    infoRow(label: "NOTAM ID", value: notam.displayId)
                    infoRow(label: "Issued", value: formatDateTime(notam.issued))
                    infoRow(label: "Location", value: notam.location)
                    infoRow(label: "FIR", value: notam.affectedFIR)
                }
            }

            // Raw NOTAM text
            GlassCard {
                VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
                    Label("Original NOTAM Text", systemImage: "doc.text")
                        .font(AviationFont.label())
                        .foregroundStyle(Color("TextTertiary"))

                    Text(notam.text)
                        .font(AviationFont.rawText())
                        .foregroundStyle(Color("TextPrimary"))
                        .textSelection(.enabled)
                }
            }

            // Q-code breakdown if available
            if let selectionCode = notam.selectionCode {
                GlassCard {
                    VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
                        Label("Q-Code", systemImage: "qrcode")
                            .font(AviationFont.label())
                            .foregroundStyle(Color("TextTertiary"))

                        Text(selectionCode)
                            .font(AviationFont.rawText())
                            .foregroundStyle(Color("ElectricCyan"))
                            .textSelection(.enabled)
                    }
                }
            }

            // Effective period
            GlassCard {
                VStack(alignment: .leading, spacing: AviationTheme.Spacing.sm) {
                    Label("Effective Period", systemImage: "calendar")
                        .font(AviationFont.label())
                        .foregroundStyle(Color("TextTertiary"))

                    infoRow(label: "From", value: formatDateTime(notam.effectiveStart))
                    if let end = notam.effectiveEnd {
                        infoRow(label: "To", value: formatDateTime(end) + (notam.isEstimatedEnd ? " (EST)" : ""))
                    } else if notam.isPermanent {
                        infoRow(label: "To", value: "PERMANENT")
                    }
                }
            }
        }
        .padding(AviationTheme.Spacing.md)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AviationFont.label())
                .foregroundStyle(Color("TextTertiary"))
            Spacer()
            Text(value)
                .font(AviationFont.rawText())
                .foregroundStyle(Color("TextPrimary"))
        }
    }

    // MARK: - Helpers

    private var typeColor: Color {
        switch notam.type {
        case .new: return Color("ElectricCyan")
        case .replacement: return Color("AmberAlert")
        case .cancellation: return Color("CrimsonPulse")
        }
    }

    private var shareText: String {
        """
        NOTAM \(notam.displayId)
        Location: \(notam.location)
        Effective: \(notam.effectivePeriodDescription)

        \(notam.text)
        """
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Tab

private enum DetailTab: String, CaseIterable, Identifiable {
    case translated = "Plain English"
    case original = "Original"

    var id: String { rawValue }
}

// MARK: - Severity Color Extension

extension NOTAMSeverity {
    var themeColor: Color {
        switch self {
        case .critical: return Color("CrimsonPulse")
        case .warning: return Color("AmberAlert")
        case .caution: return Color("AmberAlert").opacity(0.8)
        case .info: return Color("AuroraGreen")
        }
    }
}

#Preview("Warning - Runway Closure") {
    NavigationStack {
        NOTAMDetailView(notam: NOTAM(
            id: "NOTAM_1",
            series: "A",
            number: "0123/24",
            type: .new,
            issued: Date(),
            affectedFIR: "LROP",
            selectionCode: "QMRLC",
            traffic: "IV",
            purpose: "NBO",
            scope: "A",
            minimumFL: "000",
            maximumFL: "050",
            location: "LROP",
            effectiveStart: Date(),
            effectiveEnd: Date().addingTimeInterval(86400 * 7),
            isEstimatedEnd: false,
            isPermanent: false,
            text: "RWY 08R/26L CLSD DUE TO MAINT WIP. TWY A BTN TWY B AND TWY C CLSD.",
            coordinates: Coordinates(latitude: 44.57, longitude: 26.08, radius: 5)
        ))
    }
}

#Preview("Critical - Airspace Closed") {
    NavigationStack {
        NOTAMDetailView(notam: NOTAM(
            id: "UKBV_A0640",
            series: "A",
            number: "0640/22",
            type: .new,
            issued: Date(),
            affectedFIR: "UKBV",
            selectionCode: "QAFXX",
            traffic: "IV",
            purpose: "NBO",
            scope: "E",
            minimumFL: "000",
            maximumFL: "999",
            location: "UKBV",
            effectiveStart: Date(),
            effectiveEnd: nil,
            isEstimatedEnd: false,
            isPermanent: true,
            text: "DUE TO MILITARY ACTIVITY THE USE OF AIRSPACE OF UKRAINE WITHIN FIR KYIV IS PROHIBITED FOR ALL AIRCRAFT. ATS IS NOT PROVIDED.",
            coordinates: nil
        ))
    }
}
