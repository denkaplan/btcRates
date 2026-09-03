import Foundation
import Testing
@testable import n26challenge

struct MarketPricePointTests {
    @Test func usesBitcoinAsDefaultCoin() {
        let point = MarketPricePoint(date: Date(), eur: 60_000)

        #expect(point.coin == .bitcoin)
    }
}
