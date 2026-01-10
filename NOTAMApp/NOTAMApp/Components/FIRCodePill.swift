import SwiftUI

/// FIR Code Display Variants
enum FIRCodePillStyle {
    case compact   // Small inline pill
    case standard  // Normal pill with name
    case header    // Large header style
}

/// Aviation Glass FIR Code Pill Component
/// Displays FIR/ICAO code with monospace styling
struct FIRCodePill: View {
    let code: String
    var name: String? = nil
    var style: FIRCodePillStyle = .standard
    var isSelected: Bool = false

    var body: some View {
        switch style {
        case .compact:
            compactPill
        case .standard:
            standardPill
        case .header:
            headerPill
        }
    }

    // MARK: - Compact (Code Only)

    private var compactPill: some View {
        Text(code)
            .font(AviationFont.firCodeSmall())
            .foregroundStyle(isSelected ? Color("ElectricCyan") : Color("TextPrimary"))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                isSelected
                    ? Color("ElectricCyan").opacity(0.15)
                    : Color("SlateGlass")
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected
                            ? Color("ElectricCyan").opacity(0.4)
                            : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
    }

    // MARK: - Standard (Code + Name)

    private var standardPill: some View {
        HStack(spacing: 8) {
            Text(code)
                .font(AviationFont.firCodeSmall())
                .foregroundStyle(Color("ElectricCyan"))

            if let name = name {
                Text(name)
                    .font(AviationFont.bodySecondary())
                    .foregroundStyle(Color("TextSecondary"))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color("Graphite"))
        .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.small))
        .overlay(
            RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.small)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Header (Large Section Header)

    private var headerPill: some View {
        HStack(spacing: 12) {
            // FIR Code with glow
            Text(code)
                .font(AviationFont.firCode())
                .foregroundStyle(Color("TextPrimary"))
                .shadow(color: Color("ElectricCyan").opacity(0.3), radius: 4)

            if let name = name {
                Text(name)
                    .font(AviationFont.bodyPrimary())
                    .foregroundStyle(Color("TextSecondary"))
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - FIR Tag (Removable)

/// Removable FIR tag for settings
struct FIRTag: View {
    let code: String
    var name: String? = nil
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            Text(code)
                .font(AviationFont.firCodeSmall())
                .foregroundStyle(Color("ElectricCyan"))

            if let name = name {
                Text(name)
                    .font(AviationFont.caption())
                    .foregroundStyle(Color("TextTertiary"))
                    .lineLimit(1)
            }

            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color("TextTertiary"))
                        .padding(4)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, onRemove != nil ? 8 : 12)
        .padding(.vertical, 8)
        .background(Color("Graphite"))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color("ElectricCyan").opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("FIR Code Pills") {
    VStack(spacing: 32) {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compact Style")
                .font(.caption)
                .foregroundStyle(Color("TextTertiary"))

            HStack(spacing: 8) {
                FIRCodePill(code: "KJFK", style: .compact)
                FIRCodePill(code: "KLAX", style: .compact, isSelected: true)
                FIRCodePill(code: "EGLL", style: .compact)
            }
        }

        VStack(alignment: .leading, spacing: 12) {
            Text("Standard Style")
                .font(.caption)
                .foregroundStyle(Color("TextTertiary"))

            VStack(spacing: 8) {
                FIRCodePill(code: "KJFK", name: "New York JFK", style: .standard)
                FIRCodePill(code: "KLAX", name: "Los Angeles", style: .standard)
            }
        }

        VStack(alignment: .leading, spacing: 12) {
            Text("Header Style")
                .font(.caption)
                .foregroundStyle(Color("TextTertiary"))

            FIRCodePill(code: "KJFK", name: "New York JFK", style: .header)
        }

        VStack(alignment: .leading, spacing: 12) {
            Text("Removable Tags")
                .font(.caption)
                .foregroundStyle(Color("TextTertiary"))

            HStack(spacing: 8) {
                FIRTag(code: "KJFK", name: "New York") { }
                FIRTag(code: "KLAX") { }
            }
        }
    }
    .padding()
    .background(Color("DeepSpace"))
}
