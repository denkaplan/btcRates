import SwiftUI

struct BitcoinCurrencyRowView: View {
    let row: BitcoinCurrencyPresentationalModel

    var body: some View {
        HStack(spacing: 12) {
            Text(row.code)
                .font(.headline.monospaced())
                .frame(width: 48, alignment: .leading)
            Text(row.title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(row.valueText)
                .font(.body.monospacedDigit())
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(row.title), \(row.code)")
        .accessibilityValue(row.valueText)
        .accessibilityIdentifier("bitcoin-currency-row-\(row.code.lowercased())")
    }
}
