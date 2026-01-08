import SwiftUI

struct NOTAMDetailView: View {
    let notam: NOTAM

    @State private var selectedTab: DetailTab = .translated
    @State private var showShareSheet = false
    @State private var translated: TranslatedNOTAM?
    @State private var isLoadingAI = false

    private let translator = NOTAMTranslator.shared

    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            Picker("View", selection: $selectedTab) {
                ForEach(DetailTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

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
        .navigationTitle(notam.displayId)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
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
        VStack(alignment: .leading, spacing: 16) {
            if let translated {
                // Summary card
                VStack(alignment: .leading, spacing: 8) {
                    Label("Summary", systemImage: "text.alignleft")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(translated.summary)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Status indicator
                statusCard

                // Sections
                ForEach(translated.sections) { section in
                    sectionCard(section)
                }

                // Plain English text
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Plain English", systemImage: "text.bubble")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        if isLoadingAI {
                            HStack(spacing: 4) {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("AI translating...")
                                    .font(.caption2)
                            }
                            .foregroundStyle(.secondary)
                        } else if translated.aiPlainText != nil {
                            Label("AI", systemImage: "apple.intelligence")
                                .font(.caption2)
                                .foregroundStyle(.purple)
                        }
                    }

                    Text(translated.bestTranslation)
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }

    private var statusCard: some View {
        VStack(spacing: 12) {
            // Severity banner for critical/warning NOTAMs
            if notam.severity == .critical || notam.severity == .warning {
                HStack {
                    Image(systemName: notam.severity.icon)
                    Text(notam.severity.label.uppercased())
                        .font(.caption.bold())
                    Spacer()
                    Text(severityDescription)
                        .font(.caption)
                }
                .foregroundStyle(.white)
                .padding(8)
                .background(notam.severity.color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack {
                // Severity indicator
                VStack(alignment: .leading, spacing: 4) {
                    Text("Severity")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: notam.severity.icon)
                            .foregroundStyle(notam.severity.color)
                        Text(notam.severity.label)
                            .font(.subheadline.bold())
                            .foregroundStyle(notam.severity.color)
                    }
                }

                Spacer()

                // Active status
                VStack(alignment: .center, spacing: 4) {
                    Text("Status")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        Circle()
                            .fill(notam.isActive ? .green : .gray)
                            .frame(width: 8, height: 8)
                        Text(notam.isActive ? "Active" : "Inactive")
                            .font(.subheadline.bold())
                    }
                }

                Spacer()

                // Type
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Type")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(notam.type.displayName)
                        .font(.subheadline.bold())
                        .foregroundStyle(typeColor)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
        VStack(alignment: .leading, spacing: 8) {
            Label(section.title, systemImage: section.icon)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(section.content)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Original View

    private var originalView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("NOTAM ID:")
                        .foregroundStyle(.secondary)
                    Text(notam.displayId)
                        .bold()
                }

                HStack {
                    Text("Issued:")
                        .foregroundStyle(.secondary)
                    Text(notam.issued, style: .date)
                    Text(notam.issued, style: .time)
                }

                HStack {
                    Text("Location:")
                        .foregroundStyle(.secondary)
                    Text(notam.location)
                }
            }
            .font(.caption.monospaced())
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Raw NOTAM text
            VStack(alignment: .leading, spacing: 8) {
                Label("Original NOTAM Text", systemImage: "doc.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(notam.text)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Q-code breakdown if available
            if let selectionCode = notam.selectionCode {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Q-Code", systemImage: "qrcode")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(selectionCode)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }

    // MARK: - Helpers

    private var typeColor: Color {
        switch notam.type {
        case .new: return .blue
        case .replacement: return .orange
        case .cancellation: return .red
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
}

// MARK: - Tab

private enum DetailTab: String, CaseIterable, Identifiable {
    case translated = "Plain English"
    case original = "Original"

    var id: String { rawValue }
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
