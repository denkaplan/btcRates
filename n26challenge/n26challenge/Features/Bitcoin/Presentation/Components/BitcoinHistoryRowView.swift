import SwiftUI

struct BitcoinHistoryRowView: View {
    let item: BitcoinHistoryRowPresentationalModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 12)

                Text(item.priceText)
                    .font(.body.monospacedDigit())
                    .foregroundStyle(.primary)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Opens Bitcoin price details for this day")
        .accessibilityIdentifier("bitcoin-history-row-\(item.id)")
    }

    private var accessibilityLabel: String {
        [item.title, item.subtitle, item.priceText]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
