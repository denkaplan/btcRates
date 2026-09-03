import Foundation

protocol BitcoinRepository: Sendable {
    func fetchCurrentPrice(for coin: CryptoCoin) async throws -> Price
    func fetchHistoricalPrice(for coin: CryptoCoin, on date: Date) async throws -> Price
    func fetchMarketPrices(for coin: CryptoCoin, from startDate: Date, to endDate: Date) async throws -> [MarketPricePoint]
}

enum BitcoinRepositoryError: LocalizedError, Equatable, Sendable {
    case missingPrice

    var errorDescription: String? {
        switch self {
        case .missingPrice:
            return "The price is missing in the API response."
        }
    }
}
