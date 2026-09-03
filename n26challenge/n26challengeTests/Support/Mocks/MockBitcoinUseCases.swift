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

struct MockObserveBitcoinCurrentPriceUseCase: ObserveBitcoinCurrentPriceUseCase {
    let results: [Result<Price, Error>]

    func stream(interval: TimeInterval) -> AsyncStream<Result<Price, Error>> {
        AsyncStream { continuation in
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
