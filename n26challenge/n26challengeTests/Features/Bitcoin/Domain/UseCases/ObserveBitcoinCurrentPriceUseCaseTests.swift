import Foundation
import Testing
@testable import n26challenge

struct ObserveBitcoinCurrentPriceUseCaseTests {
    @Test func emitsImmediatelyAndAfterSleepInterval() async throws {
        let prices = [
            Price(date: Date(), eur: 60_000),
            Price(date: Date(), eur: 61_000)
        ]
        let useCase = ObserveBitcoinCurrentPriceUseCaseImpl(
            getCurrentPriceUseCase: SequencedCurrentPriceUseCase(results: prices)
        )
        var iterator = useCase.stream(interval: 0.01).makeAsyncIterator()

        let first = await iterator.next()
        let second = await iterator.next()

        #expect(try first?.get().eur == 60_000)
        #expect(try second?.get().eur == 61_000)
    }

    @Test func emitsFailureWhenCurrentPriceUseCaseThrows() async throws {
        let useCase = ObserveBitcoinCurrentPriceUseCaseImpl(
            getCurrentPriceUseCase: FailingCurrentPriceUseCase(error: NetworkError.unknown)
        )
        var iterator = useCase.stream(interval: 10).makeAsyncIterator()

        let first = await iterator.next()

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

private struct SequencedCurrentPriceUseCase: GetBitcoinCurrentPriceUseCase {
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

    func execute() async throws -> Price {
        await state.next()
    }
}

private struct FailingCurrentPriceUseCase: GetBitcoinCurrentPriceUseCase {
    let error: Error

    func execute() async throws -> Price {
        throw error
    }
}
