import Foundation
@testable import n26challenge

struct MockGetBitcoinHistoryUseCase: GetBitcoinHistoryUseCase {
    let result: Result<[HistoryPrice], Error>

    init(result: Result<[HistoryPrice], Error>) {
        self.result = result
    }

    func execute(daysIncludingToday: Int) async throws -> [HistoryPrice] {
        try result.get()
    }
}

@MainActor
final class MockObserveBitcoinCurrentPriceUseCase: ObserveBitcoinCurrentPriceUseCase, @unchecked Sendable {
    private var resultsByStream: [[Result<Price, Error>]]
    private(set) var streamCallCount = 0

    init(results: [Result<Price, Error>]) {
        self.resultsByStream = [results]
    }

    init(resultsByStream: [[Result<Price, Error>]]) {
        self.resultsByStream = resultsByStream
    }

    func stream(interval: TimeInterval) -> AsyncStream<Result<Price, Error>> {
        streamCallCount += 1
        let results: [Result<Price, Error>]
        if resultsByStream.isEmpty {
            results = []
        } else {
            results = resultsByStream.removeFirst()
        }

        return AsyncStream { continuation in
            results.forEach { continuation.yield($0) }
            continuation.finish()
        }
    }
}

struct MockGetBitcoinDetailPriceUseCase: GetBitcoinDetailPriceUseCase {
    let result: Result<Price, Error>

    init(result: Result<Price, Error>) {
        self.result = result
    }

    func execute(date: Date) async throws -> Price {
        try result.get()
    }
}
