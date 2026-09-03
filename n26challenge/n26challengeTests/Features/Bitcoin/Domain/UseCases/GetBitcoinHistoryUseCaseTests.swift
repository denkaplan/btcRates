import Foundation
import Testing
@testable import n26challenge

struct GetBitcoinHistoryUseCaseTests {
    @Test func buildsRequestedDaysFromMarketPricesInDescendingOrder() async throws {
        // Arrange
        let today = requiredAPIDate("02-09-2026")
        let repository = MockBitcoinRepository(
            currentPrice: Price(date: today, eur: 60_000),
            historicalPrice: Price(date: today, eur: 0),
            marketPrices: (0..<14).map { offset in
                let day = Calendar.utc.requiredDate(byAdding: .day, value: -offset, to: today)
                return MarketPricePoint(date: day, eur: Decimal(60_000 - offset))
            }
        )
        let useCase = GetBitcoinHistoryUseCaseImpl(repository: repository, todayProvider: { today })

        // Act
        let history = try await useCase.execute(daysIncludingToday: 14)

        // Assert
        #expect(history.count == 14)
        #expect(Calendar.utc.isDate(history[0].date, inSameDayAs: today))
        #expect(history[0].eur == 60_000)
        #expect(history[1].eur == 59_999)
        #expect(history.map(\.date) == history.map(\.date).sorted(by: >))
    }

    @Test func usesLatestPriceWhenMultiplePointsExistForSameDay() async throws {
        // Arrange
        let day = requiredAPIDate("01-09-2026")
        let early = day.addingTimeInterval(60)
        let late = day.addingTimeInterval(3_600)
        let useCase = GetBitcoinHistoryUseCaseImpl(repository: MockBitcoinRepository.empty)

        // Act
        let history = useCase.latestPricePerDay(from: [
            MarketPricePoint(date: early, eur: 58_000),
            MarketPricePoint(date: late, eur: 59_000)
        ])

        // Assert
        #expect(history == [HistoryPrice(date: day, eur: 59_000)])
    }

    @Test func ignoresBackendPointsOutsideRequestedUTCWindow() async throws {
        // Arrange
        let today = requiredAPIDate("02-09-2026")
        let insideStart = requiredAPIDate("01-09-2026")
        let outside = requiredAPIDate("31-08-2026")
        let repository = MockBitcoinRepository(
            currentPrice: Price(date: today, eur: 60_000),
            historicalPrice: Price(date: today, eur: 0),
            marketPrices: [
                MarketPricePoint(date: outside, eur: 57_000),
                MarketPricePoint(date: insideStart, eur: 58_000),
                MarketPricePoint(date: today, eur: 59_000)
            ]
        )
        let useCase = GetBitcoinHistoryUseCaseImpl(repository: repository, todayProvider: { today })

        // Act
        let history = try await useCase.execute(daysIncludingToday: 2)

        // Assert
        #expect(history.map(\.date) == [today, insideStart])
        #expect(history.map(\.eur) == [59_000, 58_000])
    }

    @Test func rejectsInvalidRange() async throws {
        // Arrange
        let useCase = GetBitcoinHistoryUseCaseImpl(repository: MockBitcoinRepository.empty)

        // Act
        // Assert
        await #expect(throws: BitcoinHistoryUseCaseError.invalidRange) {
            _ = try await useCase.execute(daysIncludingToday: 0)
        }
    }
}
