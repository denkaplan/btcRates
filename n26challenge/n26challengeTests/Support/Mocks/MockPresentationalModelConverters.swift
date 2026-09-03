import Foundation
@testable import n26challenge

@MainActor
final class MockBitcoinListPresentationalModelConverter: BitcoinListPresentationalModelConverter {
    private(set) var convertedHistory: [HistoryPrice] = []
    private(set) var convertedCurrentPrices: [Price] = []

    func convert(history: [HistoryPrice]) -> BitcoinListPresentationalModel {
        convertedHistory = history
        let rows = history.map(makeRow)
        return BitcoinListPresentationalModel(
            currentPriceText: rows.first?.priceText ?? "—",
            rows: rows
        )
    }

    func convert(currentPrice: Price) -> BitcoinHistoryRowPresentationalModel {
        convertedCurrentPrices.append(currentPrice)
        return BitcoinHistoryRowPresentationalModel(
            id: DateFormatter.apiDayString(from: Calendar.utc.startOfDay(for: currentPrice.date)),
            date: currentPrice.date,
            title: "Date \(DateFormatter.apiDayString(from: currentPrice.date))",
            subtitle: "Live",
            priceText: "EUR \(currentPrice.eur)"
        )
    }

    private func makeRow(_ historyPrice: HistoryPrice) -> BitcoinHistoryRowPresentationalModel {
        BitcoinHistoryRowPresentationalModel(
            id: DateFormatter.apiDayString(from: Calendar.utc.startOfDay(for: historyPrice.date)),
            date: historyPrice.date,
            title: "Date \(DateFormatter.apiDayString(from: historyPrice.date))",
            subtitle: nil,
            priceText: "EUR \(historyPrice.eur)"
        )
    }
}

struct MockBitcoinDetailPresentationalModelConverter: BitcoinDetailPresentationalModelConverter {
    let result: BitcoinDetailPresentationalModel

    func convert(price: Price) -> BitcoinDetailPresentationalModel {
        result
    }
}
