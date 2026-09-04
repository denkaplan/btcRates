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
            date: currentPrice.date,
            title: "Date \(currentPrice.date.formatted(.apiDay))",
            subtitle: "Live",
            priceText: "EUR \(currentPrice.eur)"
        )
    }

    private func makeRow(_ historyPrice: HistoryPrice) -> BitcoinHistoryRowPresentationalModel {
        BitcoinHistoryRowPresentationalModel(
            date: historyPrice.date,
            title: "Date \(historyPrice.date.formatted(.apiDay))",
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

    func convert(historyRow: BitcoinHistoryRowPresentationalModel) -> BitcoinDetailPresentationalModel {
        BitcoinDetailPresentationalModel(
            title: "Fallback title",
            dateText: historyRow.title,
            currencyRows: [BitcoinCurrencyPresentationalModel(currency: .eur, valueText: historyRow.priceText)]
        )
    }
}

struct MockLastUpdatedTextFormatter: LastUpdatedTextFormatter {
    let result: String

    init(result: String = "Updated test time") {
        self.result = result
    }

    func string(from date: Date) -> String {
        result
    }
}

struct MockErrorPresentationalModelConverter: ErrorPresentationalModelConverter {
    let result: ErrorPresentationalModel
    let livePriceRefreshResult: ErrorPresentationalModel

    init(
        result: ErrorPresentationalModel = .init(title: "Converted error", message: "Converted message", systemImage: "converted"),
        livePriceRefreshResult: ErrorPresentationalModel = .init(title: "Live converted", message: "Could not refresh live price. Pull to retry.", systemImage: "live")
    ) {
        self.result = result
        self.livePriceRefreshResult = livePriceRefreshResult
    }

    func convert(_ error: Error) -> ErrorPresentationalModel {
        result
    }

    func livePriceRefreshError() -> ErrorPresentationalModel {
        livePriceRefreshResult
    }

    func historyPriceError() -> ErrorPresentationalModel {
        result
    }
}
