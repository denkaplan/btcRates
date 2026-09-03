import Foundation

final class CoingeckoBitcoinRepositoryImpl: BitcoinRepository {
    private let networkProvider: NetworkProvider
    private let nowProvider: @Sendable () -> Date

    init(
        networkProvider: NetworkProvider,
        nowProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.networkProvider = networkProvider
        self.nowProvider = nowProvider
    }

    func fetchCurrentPrice(for coin: CryptoCoin) async throws -> Price {
        let response: SimplePriceResponse = try await networkProvider.execute(CoingeckoEndpoint.simplePrice(coin: coin))
        guard let eur = response.bitcoin.eur else { throw BitcoinRepositoryError.missingPrice }
        return Price(
            date: nowProvider(),
            eur: eur,
            usd: response.bitcoin.usd,
            gbp: response.bitcoin.gbp,
            coin: coin
        )
    }

    func fetchHistoricalPrice(for coin: CryptoCoin, on date: Date) async throws -> Price {
        let response: HistoricalPriceResponse = try await networkProvider.execute(CoingeckoEndpoint.history(coin: coin, date: date))
        guard let eur = response.marketData.currentPrice.eur else { throw BitcoinRepositoryError.missingPrice }
        return Price(
            date: date,
            eur: eur,
            usd: response.marketData.currentPrice.usd,
            gbp: response.marketData.currentPrice.gbp,
            coin: coin
        )
    }

    func fetchMarketPrices(for coin: CryptoCoin, from startDate: Date, to endDate: Date) async throws -> [MarketPricePoint] {
        let response: MarketChartResponse = try await networkProvider.execute(
            CoingeckoEndpoint.marketChartRange(coin: coin, from: startDate, to: endDate)
        )
        return response.prices.map { point in
            MarketPricePoint(
                date: Date(timeIntervalSince1970: point.timestampMilliseconds / 1000),
                eur: point.price,
                coin: coin
            )
        }
    }
}
