import Foundation

protocol ObserveBitcoinCurrentPriceUseCase: Sendable {
    func stream(interval: TimeInterval) -> AsyncStream<Result<Price, Error>>
}

enum BitcoinCurrentPriceObservationError: LocalizedError, Equatable, Sendable {
    case invalidInterval

    var errorDescription: String? {
        switch self {
        case .invalidInterval:
            return "The current-price refresh interval must be finite, greater than zero and not too large."
        }
    }
}

struct ObserveBitcoinCurrentPriceUseCaseImpl: ObserveBitcoinCurrentPriceUseCase {
    private let repository: BitcoinRepository

    init(repository: BitcoinRepository) {
        self.repository = repository
    }

    func stream(interval: TimeInterval = 60) -> AsyncStream<Result<Price, Error>> {
        AsyncStream { continuation in
            guard let refreshDelay = nanoseconds(from: interval) else {
                continuation.yield(.failure(BitcoinCurrentPriceObservationError.invalidInterval))
                continuation.finish()
                return
            }

            let task = Task {
                while !Task.isCancelled {
                    await emitCurrentPrice(into: continuation)

                    do {
                        try await Task.sleep(nanoseconds: refreshDelay)
                    } catch {
                        break
                    }
                }

                continuation.finish()
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    private func emitCurrentPrice(into continuation: AsyncStream<Result<Price, Error>>.Continuation) async {
        do {
            continuation.yield(.success(try await repository.fetchCurrentPrice(for: .bitcoin)))
        } catch {
            continuation.yield(.failure(error))
        }
    }

    private func nanoseconds(from interval: TimeInterval) -> UInt64? {
        guard interval.isFinite, interval > 0 else { return nil }
        let nanoseconds = interval * 1_000_000_000
        guard nanoseconds < TimeInterval(UInt64.max) else { return nil }
        return UInt64(nanoseconds)
    }
}
