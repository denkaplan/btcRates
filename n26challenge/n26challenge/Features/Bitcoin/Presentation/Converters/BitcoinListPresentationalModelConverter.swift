import Foundation

@MainActor
protocol BitcoinListPresentationalModelConverter {
    func convert(history: [HistoryPrice]) -> BitcoinListPresentationalModel
    func convert(currentPrice: Price) -> BitcoinHistoryRowPresentationalModel
}

@MainActor
struct BitcoinListPresentationalModelConverterImpl: BitcoinListPresentationalModelConverter {
    private let displayCurrency: Currency = .eur

    func convert(history: [HistoryPrice]) -> BitcoinListPresentationalModel {
        let rows = history.map(convert(historyPrice:))
        return BitcoinListPresentationalModel(
            currentPriceText: rows.first?.priceText ?? "—",
            rows: rows
        )
    }

    func convert(currentPrice: Price) -> BitcoinHistoryRowPresentationalModel {
        BitcoinHistoryRowPresentationalModel(
            date: currentPrice.date,
            title: currentPrice.date.formatted(.displayDay),
            subtitle: Calendar.utc.isDateInToday(currentPrice.date) ? BitcoinListRefresh.livePriceSubtitle : nil,
            priceText: format(value: currentPrice.eur, currency: displayCurrency)
        )
    }

    private func convert(historyPrice: HistoryPrice) -> BitcoinHistoryRowPresentationalModel {
        BitcoinHistoryRowPresentationalModel(
            date: historyPrice.date,
            title: historyPrice.date.formatted(.displayDay),
            subtitle: Calendar.utc.isDateInToday(historyPrice.date) ? BitcoinListRefresh.livePriceSubtitle : nil,
            priceText: format(value: historyPrice.eur, currency: displayCurrency)
        )
    }

    private func format(value: Decimal, currency: Currency) -> String {
        value.formatted(
            .currency(code: currency.code)
            .precision(.fractionLength(2))
        )
    }
}
