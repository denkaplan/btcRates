import Foundation
import Testing
@testable import n26challenge

struct PriceTests {
    @Test func usesBitcoinAsDefaultCoinAndStartOfDayIdentifier() {
        // Arrange
        let date = requiredAPIDate("02-09-2026").addingTimeInterval(3_600)
        let price = Price(date: date, eur: 60_000)

        // Act
        // Assert
        #expect(price.coin == .bitcoin)
        #expect(price.id == Calendar.utc.startOfDay(for: date))
    }
}
