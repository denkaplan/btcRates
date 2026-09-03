import Foundation
import Testing
@testable import n26challenge

struct GetBitcoinDetailPriceUseCaseTests {
    @Test func usesCurrentPriceForToday() async throws {
        let today = requiredAPIDate("02-09-2026")
        let repository = MockBitcoinRepository(
            currentPrice: Price(date: today, eur: 60_000),
            historicalPrice: Price(date: today, eur: 58_000),
            marketPrices: []
        )
        let useCase = GetBitcoinDetailPriceUseCaseImpl(repository: repository, todayProvider: { today })

        let price = try await useCase.execute(date: today.addingTimeInterval(3_600))

        #expect(price.eur == 60_000)
    }

    @Test func usesHistoricalPriceForPastDay() async throws {
        let today = requiredAPIDate("02-09-2026")
        let past = requiredAPIDate("01-09-2026")
        let repository = MockBitcoinRepository(
            currentPrice: Price(date: today, eur: 60_000),
            historicalPrice: Price(date: past, eur: 58_000, usd: 63_000, gbp: 49_000),
            marketPrices: []
        )
        let useCase = GetBitcoinDetailPriceUseCaseImpl(repository: repository, todayProvider: { today })

        let price = try await useCase.execute(date: past)

        #expect(price.eur == 58_000)
        #expect(price.usd == 63_000)
        #expect(price.gbp == 49_000)
    }
}
