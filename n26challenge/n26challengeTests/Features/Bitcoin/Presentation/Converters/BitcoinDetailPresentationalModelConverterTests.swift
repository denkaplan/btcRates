import Foundation
import Testing
@testable import n26challenge

@MainActor
struct BitcoinDetailPresentationalModelConverterTests {
    @Test func createsFallbackModelFromSelectedHistoryRow() {
        let row = BitcoinHistoryRowPresentationalModel(
            id: "today",
            date: Date(),
            title: "Today",
            subtitle: nil,
            priceText: "€60,000.00"
        )
        let converter = BitcoinDetailPresentationalModelConverterImpl()

        let model = converter.convert(historyRow: row)

        #expect(model.dateText == "Today")
        #expect(model.currencyRows.map(\.currency) == [.eur, .usd, .gbp])
        #expect(model.currencyRows[0].valueText == "€60,000.00")
        #expect(model.currencyRows[1].valueText == "—")
        #expect(model.currencyRows[2].valueText == "—")
    }

    @Test func createsReadyToRenderCurrencyRows() {
        // arrange
        let date = requiredAPIDate("03-09-2026")
        let converter = BitcoinDetailPresentationalModelConverterImpl()

        // act
        let model = converter.convert(price: Price(date: date, eur: 61_000, usd: 66_000, gbp: nil))

        // assert
        #expect(model.title == "Bitcoin exchange rate")
        #expect(model.dateText == DateFormatter.displayDay.string(from: date))
        #expect(model.currencyRows.map(\.currency) == [.eur, .usd, .gbp])
        #expect(model.currencyRows.map(\.code) == Currency.allCases.map(\.code))
        #expect(model.currencyRows.map(\.title) == Currency.allCases.map(\.description))
        #expect(model.currencyRows[0].valueText.contains("61"))
        #expect(model.currencyRows[1].valueText.contains("66"))
        #expect(model.currencyRows[2].valueText == "—")
    }
}
