import Foundation
import Testing
@testable import n26challenge

struct BitcoinRepositoryTests {
    @Test func fetchCurrentPriceMapsResponseToDomainPrice() async throws {
        let now = requiredAPIDate("02-09-2026")
        let provider = MockNetworkProvider { endpoint in
            #expect(endpoint.path == "/api/v3/simple/price")
            return SimplePriceResponse(
                bitcoin: CurrencyPriceResponse(eur: 60_000, usd: 65_000, gbp: 51_000)
            )
        }
        let repository = CoingeckoBitcoinRepository(networkProvider: provider, nowProvider: { now })

        let price = try await repository.fetchCurrentPrice(for: .bitcoin)

        #expect(price == Price(date: now, eur: 60_000, usd: 65_000, gbp: 51_000))
    }

    @Test func fetchCurrentPriceThrowsWhenEURIsMissing() async throws {
        let provider = MockNetworkProvider { _ in
            SimplePriceResponse(bitcoin: CurrencyPriceResponse(eur: nil, usd: 65_000, gbp: 51_000))
        }
        let repository = CoingeckoBitcoinRepository(networkProvider: provider)

        await #expect(throws: BitcoinRepositoryError.missingPrice) {
            _ = try await repository.fetchCurrentPrice(for: .bitcoin)
        }
    }

    @Test func fetchHistoricalPriceMapsResponseToDomainPrice() async throws {
        let date = requiredAPIDate("01-09-2026")
        let provider = MockNetworkProvider { endpoint in
            #expect(endpoint.path == "/api/v3/coins/bitcoin/history")
            return HistoricalPriceResponse(
                marketData: HistoricalMarketData(
                    currentPrice: CurrencyPriceResponse(eur: 59_000, usd: 64_000, gbp: 50_000)
                )
            )
        }
        let repository = CoingeckoBitcoinRepository(networkProvider: provider)

        let price = try await repository.fetchHistoricalPrice(for: .bitcoin, on: date)

        #expect(price == Price(date: date, eur: 59_000, usd: 64_000, gbp: 50_000))
    }

    @Test func fetchHistoricalPriceThrowsWhenEURIsMissing() async throws {
        let date = requiredAPIDate("01-09-2026")
        let provider = MockNetworkProvider { _ in
            HistoricalPriceResponse(
                marketData: HistoricalMarketData(
                    currentPrice: CurrencyPriceResponse(eur: nil, usd: 64_000, gbp: 50_000)
                )
            )
        }
        let repository = CoingeckoBitcoinRepository(networkProvider: provider)

        await #expect(throws: BitcoinRepositoryError.missingPrice) {
            _ = try await repository.fetchHistoricalPrice(for: .bitcoin, on: date)
        }
    }

    @Test func fetchMarketPricesMapsChartPointsWithoutSortingOrGrouping() async throws {
        let start = requiredAPIDate("20-08-2026")
        let end = requiredAPIDate("21-08-2026")
        let provider = MockNetworkProvider { endpoint in
            #expect(endpoint.path == "/api/v3/coins/bitcoin/market_chart/range")
            return MarketChartResponse(prices: [
                MarketChartPricePoint(timestampMilliseconds: start.timeIntervalSince1970 * 1000, price: 58_000),
                MarketChartPricePoint(timestampMilliseconds: end.timeIntervalSince1970 * 1000, price: 59_000)
            ])
        }
        let repository = CoingeckoBitcoinRepository(networkProvider: provider)

        let prices = try await repository.fetchMarketPrices(for: .bitcoin, from: start, to: end)

        #expect(prices == [
            MarketPricePoint(date: start, eur: 58_000),
            MarketPricePoint(date: end, eur: 59_000)
        ])
    }
}
