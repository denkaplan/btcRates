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
            id: rowID(for: currentPrice.date),
            date: currentPrice.date,
            title: currentPrice.date.formatted(.displayDay),
            subtitle: Calendar.utc.isDateInToday(currentPrice.date) ? "Live, refreshes every 60 seconds" : nil,
            priceText: format(value: currentPrice.eur, currency: displayCurrency)
        )
    }

    private func convert(historyPrice: HistoryPrice) -> BitcoinHistoryRowPresentationalModel {
        BitcoinHistoryRowPresentationalModel(
            id: rowID(for: historyPrice.date),
            date: historyPrice.date,
            title: historyPrice.date.formatted(.displayDay),
            subtitle: Calendar.utc.isDateInToday(historyPrice.date) ? "Live, refreshes every 60 seconds" : nil,
            priceText: format(value: historyPrice.eur, currency: displayCurrency)
        )
    }

    private func rowID(for date: Date) -> String {
        Calendar.utc.startOfDay(for: date).formatted(.apiDay)
    }

    private func format(value: Decimal, currency: Currency) -> String {
        value.formatted(
            .currency(code: currency.code)
            .precision(.fractionLength(2))
        )
    }
}
