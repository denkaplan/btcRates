import Foundation
import Testing
@testable import n26challenge

struct CoinGeckoAPITests {
    @Test func simplePriceEndpointContainsCoinAndCurrencyQuery() {
        let endpoint = CoingeckoEndpoint.simplePrice(coin: .bitcoin)

        #expect(endpoint.path == "/api/v3/simple/price")
        #expect(endpoint.method == .GET)
        #expect(endpoint.queryParams.contains { $0.key == "ids" && $0.value == CryptoCoin.bitcoin.apiIdentifier })
        #expect(endpoint.queryParams.contains { $0.key == "vs_currencies" && $0.value == Currency.allCases.map(\.apiCode).joined(separator: ",") })
    }

    @Test func marketChartRangeEndpointContainsCurrencyAndTimestampRange() {
        let start = requiredAPIDate("20-08-2026")
        let end = requiredAPIDate("21-08-2026")

        let endpoint = CoingeckoEndpoint.marketChartRange(coin: .bitcoin, from: start, to: end)

        #expect(endpoint.path == "/api/v3/coins/bitcoin/market_chart/range")
        #expect(endpoint.queryParams.contains { $0.key == "vs_currency" && $0.value == Currency.eur.apiCode })
        #expect(endpoint.queryParams.contains { $0.key == "from" && $0.value == String(Int(start.timeIntervalSince1970)) })
        #expect(endpoint.queryParams.contains { $0.key == "to" && $0.value == String(Int(Calendar.utc.endOfDay(for: end).timeIntervalSince1970)) })
    }

    @Test func historyEndpointContainsDateAndLocalizationQuery() {
        let date = requiredAPIDate("01-09-2026")

        let endpoint = CoingeckoEndpoint.history(coin: .bitcoin, date: date)

        #expect(endpoint.path == "/api/v3/coins/bitcoin/history")
        #expect(endpoint.queryParams.contains { $0.key == "date" && $0.value == "01-09-2026" })
        #expect(endpoint.queryParams.contains { $0.key == "localization" && $0.value == "false" })
    }

    @Test func marketChartPricePointDecodesFromCoingeckoArrayShape() throws {
        let json = Data("""
        [[1788307200000,58000.25]]
        """.utf8)

        let points = try JSONDecoder().decode([MarketChartPricePoint].self, from: json)

        #expect(points == [MarketChartPricePoint(timestampMilliseconds: 1_788_307_200_000, price: requiredDecimal("58000.25"))])
    }

    @Test func historicalResponseDecodesUsingSnakeCaseDecoder() throws {
        let json = Data("""
        {
          "market_data": {
            "current_price": {
              "eur": 59000,
              "usd": 64000,
              "gbp": 50000
            }
          }
        }
        """.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let response = try decoder.decode(HistoricalPriceResponse.self, from: json)

        #expect(response.marketData.currentPrice.eur == 59_000)
        #expect(response.marketData.currentPrice.usd == 64_000)
        #expect(response.marketData.currentPrice.gbp == 50_000)
    }
}
