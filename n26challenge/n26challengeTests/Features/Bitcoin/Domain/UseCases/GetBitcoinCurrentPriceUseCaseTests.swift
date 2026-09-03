import Foundation
import Testing
@testable import n26challenge

struct GetBitcoinCurrentPriceUseCaseTests {
    @Test func delegatesToRepository() async throws {
        let expected = Price(date: Date(), eur: 60_000)
        let useCase = GetBitcoinCurrentPriceUseCaseImpl(
            repository: MockBitcoinRepository(currentPrice: expected, historicalPrice: expected, marketPrices: [])
        )

        let price = try await useCase.execute()

        #expect(price == expected)
    }
}
