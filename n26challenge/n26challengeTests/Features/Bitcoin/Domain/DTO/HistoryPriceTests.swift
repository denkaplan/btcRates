import Foundation
import Testing
@testable import n26challenge

struct HistoryPriceTests {
    @Test func usesBitcoinAsDefaultCoinAndStartOfDayIdentifier() {
        // Arrange
        let date = requiredAPIDate("02-09-2026").addingTimeInterval(3_600)
        let historyPrice = HistoryPrice(date: date, eur: 60_000)

        // Act
        // Assert
        #expect(historyPrice.coin == .bitcoin)
        #expect(historyPrice.id == Calendar.utc.startOfDay(for: date))
    }
}
