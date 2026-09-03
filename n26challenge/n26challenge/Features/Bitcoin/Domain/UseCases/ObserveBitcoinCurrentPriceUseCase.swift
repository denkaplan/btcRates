import Foundation

protocol ObserveBitcoinCurrentPriceUseCase: Sendable {
    func stream(interval: TimeInterval) -> AsyncStream<Result<Price, Error>>
}

struct ObserveBitcoinCurrentPriceUseCaseImpl: ObserveBitcoinCurrentPriceUseCase {
    private let repository: BitcoinRepository

    init(repository: BitcoinRepository) {
        self.repository = repository
    }

    func stream(interval: TimeInterval = 60) -> AsyncStream<Result<Price, Error>> {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    await emitCurrentPrice(into: continuation)

                    do {
                        try await Task.sleep(nanoseconds: nanoseconds(from: interval))
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

    private func nanoseconds(from interval: TimeInterval) -> UInt64 {
        guard interval > 0 else { return 0 }
        let nanoseconds = interval * 1_000_000_000
        guard nanoseconds < TimeInterval(UInt64.max) else { return UInt64.max }
        return UInt64(nanoseconds)
    }
}
