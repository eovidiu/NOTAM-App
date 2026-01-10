import SwiftUI

/// Aviation Glass Premium Search Bar Component
/// Glass morphism search field with focus animation
struct PremiumSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search NOTAMs..."
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        HStack(spacing: 12) {
            // Search Icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isFocused ? Color("ElectricCyan") : Color("TextTertiary"))

            // Text Field
            TextField(placeholder, text: $text)
                .font(AviationFont.bodyPrimary())
                .foregroundStyle(Color("TextPrimary"))
                .focused($isFocused)
                .onSubmit { onSubmit?() }
                .tint(Color("ElectricCyan"))

            // Clear Button
            if !text.isEmpty {
                Button {
                    text = ""
                    HapticManager.shared.light()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color("TextTertiary"))
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium))
        .overlay(borderOverlay)
        .animation(AviationAnimation.quick, value: isFocused)
        .animation(AviationAnimation.quick, value: text.isEmpty)
    }

    @ViewBuilder
    private var backgroundView: some View {
        if reduceTransparency {
            Color("Graphite")
        } else {
            ZStack {
                Color("Graphite")

                // Subtle inner gradient
                LinearGradient(
                    colors: [
                        Color.white.opacity(isFocused ? 0.06 : 0.03),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: AviationTheme.CornerRadius.medium)
            .stroke(
                isFocused
                    ? Color("ElectricCyan").opacity(0.5)
                    : Color.white.opacity(0.1),
                lineWidth: isFocused ? 1.5 : 1
            )
    }
}

// MARK: - Compact Search Bar

/// Smaller search bar for inline use
struct CompactSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color("TextTertiary"))

            TextField(placeholder, text: $text)
                .font(AviationFont.bodySecondary())
                .foregroundStyle(Color("TextPrimary"))
                .focused($isFocused)
                .tint(Color("ElectricCyan"))

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color("TextTertiary"))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color("SlateGlass"))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(
                    isFocused
                        ? Color("ElectricCyan").opacity(0.4)
                        : Color.white.opacity(0.08),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Preview

#Preview("Search Bars") {
    VStack(spacing: 32) {
        VStack(alignment: .leading, spacing: 12) {
            Text("Premium Search Bar")
                .font(.caption)
                .foregroundStyle(Color("TextTertiary"))

            PremiumSearchBar(text: .constant(""))

            PremiumSearchBar(text: .constant("KJFK"))
        }

        VStack(alignment: .leading, spacing: 12) {
            Text("Compact Search Bar")
                .font(.caption)
                .foregroundStyle(Color("TextTertiary"))

            CompactSearchBar(text: .constant(""))

            CompactSearchBar(text: .constant("runway"))
        }
    }
    .padding()
    .background(Color("DeepSpace"))
}
