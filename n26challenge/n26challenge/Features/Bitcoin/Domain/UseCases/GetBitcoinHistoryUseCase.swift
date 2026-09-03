import Foundation

protocol GetBitcoinHistoryUseCase: Sendable {
    func execute(daysIncludingToday: Int) async throws -> [HistoryPrice]
}

enum BitcoinHistoryUseCaseError: LocalizedError, Equatable, Sendable {
    case invalidRange

    var errorDescription: String? {
        switch self {
        case .invalidRange:
            return "The requested date range is invalid."
        }
    }
}

struct GetBitcoinHistoryUseCaseImpl: GetBitcoinHistoryUseCase {
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

    func execute(daysIncludingToday: Int = 14) async throws -> [HistoryPrice] {
        guard daysIncludingToday > 0 else { throw BitcoinHistoryUseCaseError.invalidRange }

        let today = calendar.startOfDay(for: todayProvider())
        let startDate = calendar.requiredDate(byAdding: .day, value: -(daysIncludingToday - 1), to: today)
        let pricePoints = try await repository.fetchMarketPrices(for: .bitcoin, from: startDate, to: today)

        return latestPricePerDay(from: pricePoints)
            .reduce(into: [Date: HistoryPrice]()) { uniqueItems, item in
                uniqueItems[calendar.startOfDay(for: item.date)] = item
            }
            .values
            .sorted { $0.date > $1.date }
    }

    func latestPricePerDay(from pricePoints: [MarketPricePoint]) -> [HistoryPrice] {
        let groupedByDay = Dictionary(grouping: pricePoints) { pricePoint in
            calendar.startOfDay(for: pricePoint.date)
        }

        return groupedByDay.compactMap { date, points in
            guard let latestPoint = points.max(by: { $0.date < $1.date }) else { return nil }
            return HistoryPrice(date: date, eur: latestPoint.eur, coin: latestPoint.coin)
        }
    }
}
