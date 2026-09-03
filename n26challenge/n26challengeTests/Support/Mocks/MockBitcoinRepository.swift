import Foundation
@testable import n26challenge

struct MockBitcoinRepository: BitcoinRepository {
    static let empty = MockBitcoinRepository(
        currentPrice: Price(date: Date(), eur: 0),
        historicalPrice: Price(date: Date(), eur: 0),
        marketPrices: []
    )

    let currentPrice: Price
    let historicalPrice: Price
    let marketPrices: [MarketPricePoint]

    func fetchCurrentPrice(for coin: CryptoCoin) async throws -> Price { currentPrice }
    func fetchHistoricalPrice(for coin: CryptoCoin, on date: Date) async throws -> Price { historicalPrice }
    func fetchMarketPrices(for coin: CryptoCoin, from startDate: Date, to endDate: Date) async throws -> [MarketPricePoint] { marketPrices }
}
