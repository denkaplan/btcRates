import SwiftUI

struct LivePriceHeader: View {
    let priceText: String
    let lastUpdatedText: String?
    let height: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("BTC / EUR")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))

                Spacer(minLength: 12)

                if let lastUpdatedText {
                    Text(lastUpdatedText)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(1)
                }
            }

            Text(priceText)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text("Live Bitcoin price")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .bottomLeading)
        .padding(.horizontal, 24)
        .padding(.top, 44)
        .padding(.bottom, 22)
        .background(ColorPalette.accentGradient)
        .clipShape(BottomRoundedRectangle(radius: 28))
        .shadow(color: ColorPalette.accent.opacity(0.18), radius: 18, x: 0, y: 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("BTC to EUR live Bitcoin price")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("bitcoin-live-price-header")
    }

    private var accessibilityValue: String {
        if let lastUpdatedText {
            return "\(priceText), \(lastUpdatedText)"
        }
        return priceText
    }
}
