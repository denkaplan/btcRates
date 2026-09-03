import Foundation
import CoreFoundationKit

protocol BitcoinRepository {
    func currentPrice() async throws -> BitcoinPrice
    func historicalPrices(daysIncludingToday: Int) async throws -> [BitcoinHistoryItem]
    func details(for date: Date) async throws -> BitcoinPrice
}

enum BitcoinRepositoryError: LocalizedError, Equatable {
    case invalidRange
    case missingPrice

    var errorDescription: String? {
        switch self {
        case .invalidRange:
            return "The requested date range is invalid."
        case .missingPrice:
            return "The price is missing in the API response."
        }
    }
}

struct CoingeckoBitcoinRepository: BitcoinRepository {
    private let networkProvider: NetworkProvider
    private let calendar: Calendar
    private let todayProvider: () -> Date

    init(
        networkProvider: NetworkProvider,
        calendar: Calendar = .utc,
        todayProvider: @escaping () -> Date = Date.init
    ) {
        self.networkProvider = networkProvider
        self.calendar = calendar
        self.todayProvider = todayProvider
    }

    func currentPrice() async throws -> BitcoinPrice {
        let response: SimplePriceResponse = try await networkProvider.execute(CoingeckoEndpoint.simplePrice)
        guard let eur = response.bitcoin.eur else { throw BitcoinRepositoryError.missingPrice }
        return BitcoinPrice(date: calendar.startOfDay(for: todayProvider()), eur: eur, usd: response.bitcoin.usd, gbp: response.bitcoin.gbp)
    }

    func historicalPrices(daysIncludingToday: Int = 14) async throws -> [BitcoinHistoryItem] {
        guard daysIncludingToday > 0 else { throw BitcoinRepositoryError.invalidRange }

        let today = calendar.startOfDay(for: todayProvider())
        async let historical = historicalEURPrices(before: today, count: max(daysIncludingToday - 1, 0))
        async let current = currentPrice()

        var items = try await historical
        let currentPrice = try await current
        items.append(BitcoinHistoryItem(date: today, eur: currentPrice.eur))
        return items.sorted { $0.date > $1.date }
    }

    func details(for date: Date) async throws -> BitcoinPrice {
        let day = calendar.startOfDay(for: date)
        if calendar.isDate(day, inSameDayAs: todayProvider()) {
            return try await currentPrice()
        }

        let response: HistoricalPriceResponse = try await networkProvider.execute(CoingeckoEndpoint.history(date: day))
        guard let eur = response.marketData.currentPrice.eur else { throw BitcoinRepositoryError.missingPrice }
        return BitcoinPrice(
            date: day,
            eur: eur,
            usd: response.marketData.currentPrice.usd,
            gbp: response.marketData.currentPrice.gbp
        )
    }

    private func historicalEURPrices(before today: Date, count: Int) async throws -> [BitcoinHistoryItem] {
        guard count > 0 else { return [] }
        let end = calendar.date(byAdding: .day, value: -1, to: today)!
        let start = calendar.date(byAdding: .day, value: -(count - 1), to: end)!
        let response: MarketChartResponse = try await networkProvider.execute(CoingeckoEndpoint.marketChartRange(from: start, to: end))

        let groupedByDay = Dictionary(grouping: response.prices) { pricePoint in
            calendar.startOfDay(for: Date(timeIntervalSince1970: pricePoint.timestampMilliseconds / 1000))
        }

        return groupedByDay
            .compactMap { date, points -> BitcoinHistoryItem? in
                guard let latestPoint = points.max(by: { $0.timestampMilliseconds < $1.timestampMilliseconds }) else { return nil }
                return BitcoinHistoryItem(date: date, eur: latestPoint.price)
            }
            .sorted { $0.date < $1.date }
    }
}

private enum CoingeckoEndpoint {
    typealias EmptyBody = [String: String]

    static var simplePrice: EndpointBuilder<SimplePriceResponse, EmptyBody> {
        EndpointBuilder<SimplePriceResponse, EmptyBody>("/api/v3/simple/price")
            .withQuery("ids", "bitcoin")
            .withQuery("vs_currencies", "eur,usd,gbp")
    }

    static func marketChartRange(from start: Date, to end: Date) -> EndpointBuilder<MarketChartResponse, EmptyBody> {
        EndpointBuilder<MarketChartResponse, EmptyBody>("/api/v3/coins/bitcoin/market_chart/range")
            .withQuery("vs_currency", "eur")
            .withQuery("from", String(Int(start.timeIntervalSince1970)))
            .withQuery("to", String(Int(end.addingTimeInterval(86_399).timeIntervalSince1970)))
    }

    static func history(date: Date) -> EndpointBuilder<HistoricalPriceResponse, EmptyBody> {
        EndpointBuilder<HistoricalPriceResponse, EmptyBody>("/api/v3/coins/bitcoin/history")
            .withQuery("date", DateFormatter.apiDay.string(from: date))
            .withQuery("localization", "false")
    }
}

struct SimplePriceResponse: Decodable, Equatable {
    let bitcoin: CurrencyPriceResponse
}

struct CurrencyPriceResponse: Decodable, Equatable {
    let eur: Decimal?
    let usd: Decimal?
    let gbp: Decimal?
}

struct HistoricalPriceResponse: Decodable, Equatable {
    let marketData: HistoricalMarketData

    enum CodingKeys: String, CodingKey {
        case marketData = "market_data"
    }
}

struct HistoricalMarketData: Decodable, Equatable {
    let currentPrice: CurrencyPriceResponse

    enum CodingKeys: String, CodingKey {
        case currentPrice = "current_price"
    }
}

struct MarketChartResponse: Decodable, Equatable {
    let prices: [PricePoint]
}

struct PricePoint: Decodable, Equatable {
    let timestampMilliseconds: TimeInterval
    let price: Decimal

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        timestampMilliseconds = try container.decode(TimeInterval.self)
        price = try container.decode(Decimal.self)
    }

    init(timestampMilliseconds: TimeInterval, price: Decimal) {
        self.timestampMilliseconds = timestampMilliseconds
        self.price = price
    }
}
