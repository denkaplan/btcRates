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

final class MockObserveBitcoinCurrentPriceUseCase: ObserveBitcoinCurrentPriceUseCase, @unchecked Sendable {
    private let lock = NSLock()
    private var resultsByStream: [[Result<Price, Error>]]
    private var streamCalls = 0

    var streamCallCount: Int {
        lock.withLock { streamCalls }
    }

    init(results: [Result<Price, Error>]) {
        self.resultsByStream = [results]
    }

    init(resultsByStream: [[Result<Price, Error>]]) {
        self.resultsByStream = resultsByStream
    }

    func stream(interval: TimeInterval) -> AsyncStream<Result<Price, Error>> {
        let results: [Result<Price, Error>] = lock.withLock {
            streamCalls += 1
            if resultsByStream.isEmpty {
                return []
            }
            return resultsByStream.removeFirst()
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
