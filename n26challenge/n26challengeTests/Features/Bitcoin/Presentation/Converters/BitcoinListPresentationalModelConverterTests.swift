import Foundation
import Testing
@testable import n26challenge

@MainActor
struct BitcoinListPresentationalModelConverterTests {
    @Test func createsReadyToRenderRowsAndHeaderPrice() {
        // Arrange
        let today = Calendar.utc.startOfDay(for: Date())
        let yesterday = Calendar.utc.requiredDate(byAdding: .day, value: -1, to: today)
        let converter = BitcoinListPresentationalModelConverterImpl()

        // Act
        let model = converter.convert(history: [
            HistoryPrice(date: today, eur: 61_000),
            HistoryPrice(date: yesterday, eur: 60_000)
        ])

        // Assert
        #expect(model.currentPriceText.contains("61"))
        #expect(model.rows.count == 2)
        #expect(model.rows[0].id == DateFormatter.apiDayString(from: today))
        #expect(model.rows[0].title == DateFormatter.displayDay.string(from: today))
        #expect(model.rows[0].subtitle == "Live, refreshes every 60 seconds")
        #expect(model.rows[0].priceText.contains("61"))
        #expect(model.rows[1].subtitle == nil)
        #expect(model.rows[1].priceText.contains("60"))
    }

    @Test func createsReadyToRenderRowForCurrentPrice() {
        // Arrange
        let date = Calendar.utc.startOfDay(for: Date())
        let converter = BitcoinListPresentationalModelConverterImpl()

        // Act
        let row = converter.convert(currentPrice: Price(date: date, eur: 62_000))

        // Assert
        #expect(row.id == DateFormatter.apiDayString(from: date))
        #expect(row.title == DateFormatter.displayDay.string(from: date))
        #expect(row.subtitle == "Live, refreshes every 60 seconds")
        #expect(row.priceText.contains("62"))
    }
}
