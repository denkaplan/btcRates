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
            title: DateFormatter.displayDay.string(from: currentPrice.date),
            subtitle: Calendar.utc.isDateInToday(currentPrice.date) ? "Live, refreshes every 60 seconds" : nil,
            priceText: format(value: currentPrice.eur, currency: displayCurrency)
        )
    }

    private func convert(historyPrice: HistoryPrice) -> BitcoinHistoryRowPresentationalModel {
        BitcoinHistoryRowPresentationalModel(
            id: rowID(for: historyPrice.date),
            date: historyPrice.date,
            title: DateFormatter.displayDay.string(from: historyPrice.date),
            subtitle: Calendar.utc.isDateInToday(historyPrice.date) ? "Live, refreshes every 60 seconds" : nil,
            priceText: format(value: historyPrice.eur, currency: displayCurrency)
        )
    }

    private func rowID(for date: Date) -> String {
        DateFormatter.apiDayString(from: Calendar.utc.startOfDay(for: date))
    }

    private func format(value: Decimal, currency: Currency) -> String {
        NumberFormatter.currency(currency).string(from: value.asNumber) ?? "\(currency.fallbackPrefix)\(value)"
    }
}
