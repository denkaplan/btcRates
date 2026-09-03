import Foundation
import Testing
@testable import n26challenge

struct ObserveBitcoinCurrentPriceUseCaseTests {
    @Test func emitsImmediatelyAndAfterSleepInterval() async throws {
        // Arrange
        let prices = [
            Price(date: Date(), eur: 60_000),
            Price(date: Date(), eur: 61_000)
        ]
        let useCase = ObserveBitcoinCurrentPriceUseCaseImpl(
            repository: SequencedCurrentPriceRepository(results: prices)
        )
        var iterator = useCase.stream(interval: 0.01).makeAsyncIterator()

        // Act
        let first = await iterator.next()
        let second = await iterator.next()

        // Assert
        #expect(try first?.get().eur == 60_000)
        #expect(try second?.get().eur == 61_000)
    }

    @Test func emitsFailureWhenRepositoryThrows() async throws {
        // Arrange
        let useCase = ObserveBitcoinCurrentPriceUseCaseImpl(
            repository: FailingCurrentPriceRepository(error: NetworkError.unknown)
        )
        var iterator = useCase.stream(interval: 10).makeAsyncIterator()

        // Act
        let first = await iterator.next()

        // Assert
        do {
            _ = try first?.get()
            Issue.record("Expected current price stream to emit a failure")
        } catch NetworkError.unknown {
            // Expected.
        } catch {
            Issue.record("Expected NetworkError.unknown, got \(error)")
        }
    }
}

private struct SequencedCurrentPriceRepository: BitcoinRepository {
    private actor State {
        var results: [Price]

        init(results: [Price]) {
            self.results = results
        }

        func next() -> Price {
            results.removeFirst()
        }
    }

    private let state: State

    init(results: [Price]) {
        self.state = State(results: results)
    }

    func fetchCurrentPrice(for coin: CryptoCoin) async throws -> Price {
        await state.next()
    }

    func fetchHistoricalPrice(for coin: CryptoCoin, on date: Date) async throws -> Price {
        throw NetworkError.unknown
    }

    func fetchMarketPrices(for coin: CryptoCoin, from startDate: Date, to endDate: Date) async throws -> [MarketPricePoint] {
        []
    }
}

private struct FailingCurrentPriceRepository: BitcoinRepository {
    let error: Error

    func fetchCurrentPrice(for coin: CryptoCoin) async throws -> Price {
        throw error
    }

    func fetchHistoricalPrice(for coin: CryptoCoin, on date: Date) async throws -> Price {
        throw error
    }

    func fetchMarketPrices(for coin: CryptoCoin, from startDate: Date, to endDate: Date) async throws -> [MarketPricePoint] {
        throw error
    }
}
