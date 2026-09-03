import Foundation

protocol GetBitcoinCurrentPriceUseCase: Sendable {
    func execute() async throws -> Price
}

struct GetBitcoinCurrentPriceUseCaseImpl: GetBitcoinCurrentPriceUseCase {
    private let repository: BitcoinRepository

    init(repository: BitcoinRepository) {
        self.repository = repository
    }

    func execute() async throws -> Price {
        try await repository.fetchCurrentPrice(for: .bitcoin)
    }
}
