//
//  CoinGeckoAPI.swift
//  n26challenge
//
//  Created by Kaplan, Deniz on 03.09.26.
//

import Foundation

enum CoingeckoEndpoint {
    typealias EmptyBody = [String: String]

    static func simplePrice(coin: CryptoCoin, currencies: [Currency] = [.eur, .usd, .gbp]) -> EndpointBuilder<SimplePriceResponse, EmptyBody> {
        EndpointBuilder<SimplePriceResponse, EmptyBody>("/api/v3/simple/price")
            .withQuery("ids", coin.apiIdentifier)
            .withQuery("vs_currencies", currencies.map(\.apiCode).joined(separator: ","))
    }

    static func marketChartRange(coin: CryptoCoin, currency: Currency = .eur, from startDate: Date, to endDate: Date) -> EndpointBuilder<MarketChartResponse, EmptyBody> {
        EndpointBuilder<MarketChartResponse, EmptyBody>("/api/v3/coins/\(coin.apiIdentifier)/market_chart/range")
            .withQuery("vs_currency", currency.apiCode)
            .withQuery("from", timestampString(for: startDate))
            .withQuery("to", timestampString(for: Calendar.utc.endOfDay(for: endDate)))
    }

    static func history(coin: CryptoCoin, date: Date) -> EndpointBuilder<HistoricalPriceResponse, EmptyBody> {
        EndpointBuilder<HistoricalPriceResponse, EmptyBody>("/api/v3/coins/\(coin.apiIdentifier)/history")
            .withQuery("date", DateFormatter.apiDayString(from: date))
            .withQuery("localization", "false")
    }
    private static func timestampString(for date: Date) -> String {
        String(Int(date.timeIntervalSince1970))
    }
}

// MARK: Response

struct SimplePriceResponse: Decodable, Equatable, Sendable {
    let bitcoin: CurrencyPriceResponse
}

struct CurrencyPriceResponse: Decodable, Equatable, Sendable {
    let eur: Decimal?
    let usd: Decimal?
    let gbp: Decimal?
}

struct HistoricalPriceResponse: Decodable, Equatable, Sendable {
    let marketData: HistoricalMarketData
}

struct HistoricalMarketData: Decodable, Equatable, Sendable {
    let currentPrice: CurrencyPriceResponse
}

struct MarketChartResponse: Decodable, Equatable, Sendable {
    let prices: [MarketChartPricePoint]
}

struct MarketChartPricePoint: Decodable, Equatable, Sendable {
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
