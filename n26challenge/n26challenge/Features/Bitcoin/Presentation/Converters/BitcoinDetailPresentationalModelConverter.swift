import Foundation

@MainActor
protocol BitcoinDetailPresentationalModelConverter {
    func convert(price: Price) -> BitcoinDetailPresentationalModel
    func convert(historyRow: BitcoinHistoryRowPresentationalModel) -> BitcoinDetailPresentationalModel
}

@MainActor
struct BitcoinDetailPresentationalModelConverterImpl: BitcoinDetailPresentationalModelConverter {
    func convert(price: Price) -> BitcoinDetailPresentationalModel {
        BitcoinDetailPresentationalModel(
            title: "Bitcoin exchange rate",
            dateText: DateFormatter.displayDay.string(from: price.date),
            currencyRows: Currency.allCases.map { currency in
                BitcoinCurrencyPresentationalModel(
                    currency: currency,
                    valueText: format(value: price.value(for: currency), currency: currency)
                )
            }
        )
    }

    func convert(historyRow: BitcoinHistoryRowPresentationalModel) -> BitcoinDetailPresentationalModel {
        BitcoinDetailPresentationalModel(
            title: "Bitcoin exchange rate",
            dateText: historyRow.title,
            currencyRows: Currency.allCases.map { currency in
                BitcoinCurrencyPresentationalModel(
                    currency: currency,
                    valueText: currency == .eur ? historyRow.priceText : "—"
                )
            }
        )
    }

    private func format(value: Decimal?, currency: Currency) -> String {
        guard let value else { return "—" }
        return NumberFormatter.currency(currency).string(from: value.asNumber) ?? "\(currency.fallbackPrefix)\(value)"
    }
}

private extension Price {
    func value(for currency: Currency) -> Decimal? {
        switch currency {
        case .eur:
            return eur
        case .usd:
            return usd
        case .gbp:
            return gbp
        }
    }
}
