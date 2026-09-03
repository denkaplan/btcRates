import Foundation
import Testing
@testable import n26challenge

struct MarketPricePointTests {
    @Test func usesBitcoinAsDefaultCoin() {
        // Arrange
        let point = MarketPricePoint(date: Date(), eur: 60_000)

        // Act
        // Assert
        #expect(point.coin == .bitcoin)
    }
}
