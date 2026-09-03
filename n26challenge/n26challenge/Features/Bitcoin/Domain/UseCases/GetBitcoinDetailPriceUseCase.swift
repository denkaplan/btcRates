import Foundation

protocol GetBitcoinDetailPriceUseCase: Sendable {
    func execute(date: Date) async throws -> Price
}

struct GetBitcoinDetailPriceUseCaseImpl: GetBitcoinDetailPriceUseCase {
    private let repository: BitcoinRepository
    private let calendar: Calendar
    private let todayProvider: @Sendable () -> Date

    init(
        repository: BitcoinRepository,
        calendar: Calendar = .utc,
        todayProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.repository = repository
        self.calendar = calendar
        self.todayProvider = todayProvider
    }

    func execute(date: Date) async throws -> Price {
        let requestedDay = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: todayProvider())
        if calendar.isDate(requestedDay, inSameDayAs: today) {
            return try await repository.fetchCurrentPrice(for: .bitcoin)
        }
        return try await repository.fetchHistoricalPrice(for: .bitcoin, on: requestedDay)
    }
}
