import Foundation
import Testing
@testable import n26challenge

@MainActor
struct BitcoinListViewModelTests {
    @Test func onAppearLoadsHistoryAndMergesCurrentPriceFromStream() async throws {
        let today = Calendar.utc.startOfDay(for: Date())
        let history = [
            HistoryPrice(date: today, eur: 60_000),
            HistoryPrice(date: Calendar.utc.requiredDate(byAdding: .day, value: -1, to: today), eur: 59_000)
        ]
        let converter = MockBitcoinListPresentationalModelConverter()
        let viewModel = BitcoinListViewModel(
            getBitcoinHistoryUseCase: MockGetBitcoinHistoryUseCase(result: .success(history)),
            observeBitcoinCurrentPriceUseCase: MockObserveBitcoinCurrentPriceUseCase(results: [
                .success(Price(date: today, eur: 61_000, usd: 66_000, gbp: 52_000))
            ]),
            presentationalModelConverter: converter,
            errorPresentationalModelConverter: MockErrorPresentationalModelConverter(),
            lastUpdatedTextFormatter: MockLastUpdatedTextFormatter(),
            onSelect: { _ in }
        )

        viewModel.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        guard case .loaded(let rows, let message) = viewModel.contentState else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(rows.count == 2)
        #expect(rows.first?.priceText == "EUR 61000")
        #expect(message == nil)
        #expect(viewModel.currentPriceText == "EUR 61000")
        #expect(viewModel.lastUpdatedText == "Updated test time")
        #expect(converter.convertedHistory == history)
        #expect(converter.convertedCurrentPrices.map(\.eur) == [61_000])
    }

    @Test func retryRefreshesHistory() async throws {
        let refreshed = [HistoryPrice(date: Date(), eur: 62_000)]
        let viewModel = BitcoinListViewModel(
            getBitcoinHistoryUseCase: MockGetBitcoinHistoryUseCase(result: .success(refreshed)),
            observeBitcoinCurrentPriceUseCase: MockObserveBitcoinCurrentPriceUseCase(results: []),
            presentationalModelConverter: MockBitcoinListPresentationalModelConverter(),
            errorPresentationalModelConverter: MockErrorPresentationalModelConverter(),
            lastUpdatedTextFormatter: MockLastUpdatedTextFormatter(),
            onSelect: { _ in }
        )

        viewModel.retry()
        try await Task.sleep(nanoseconds: 100_000_000)

        guard case .loaded(let rows, let message) = viewModel.contentState else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(rows.map(\.priceText) == ["EUR 62000"])
        #expect(message == nil)
        #expect(viewModel.currentPriceText == "EUR 62000")
    }

    @Test func loadHistoryFailureShowsFailedState() async throws {
        let viewModel = BitcoinListViewModel(
            getBitcoinHistoryUseCase: MockGetBitcoinHistoryUseCase(result: .failure(NetworkError.unknown)),
            observeBitcoinCurrentPriceUseCase: MockObserveBitcoinCurrentPriceUseCase(results: []),
            presentationalModelConverter: MockBitcoinListPresentationalModelConverter(),
            errorPresentationalModelConverter: MockErrorPresentationalModelConverter(),
            lastUpdatedTextFormatter: MockLastUpdatedTextFormatter(),
            onSelect: { _ in }
        )

        viewModel.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        guard case .failed(let message) = viewModel.contentState else {
            Issue.record("Expected failed state")
            return
        }
        #expect(message == MockErrorPresentationalModelConverter().result)
    }

    @Test func currentPriceFailureUsesFailedStateWhenRowsAreEmpty() async throws {
        let viewModel = BitcoinListViewModel(
            getBitcoinHistoryUseCase: MockGetBitcoinHistoryUseCase(result: .success([])),
            observeBitcoinCurrentPriceUseCase: MockObserveBitcoinCurrentPriceUseCase(results: [.failure(NetworkError.timeout)]),
            presentationalModelConverter: MockBitcoinListPresentationalModelConverter(),
            errorPresentationalModelConverter: MockErrorPresentationalModelConverter(),
            lastUpdatedTextFormatter: MockLastUpdatedTextFormatter(),
            onSelect: { _ in }
        )

        viewModel.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        guard case .failed(let message) = viewModel.contentState else {
            Issue.record("Expected failed state")
            return
        }
        #expect(message == MockErrorPresentationalModelConverter().result)
    }

    @Test func currentPriceFailureUsesInlineRefreshMessageWhenRowsAlreadyExist() async throws {
        let viewModel = BitcoinListViewModel(
            getBitcoinHistoryUseCase: MockGetBitcoinHistoryUseCase(result: .success([HistoryPrice(date: Date(), eur: 60_000)])),
            observeBitcoinCurrentPriceUseCase: MockObserveBitcoinCurrentPriceUseCase(results: [.failure(NetworkError.timeout)]),
            presentationalModelConverter: MockBitcoinListPresentationalModelConverter(),
            errorPresentationalModelConverter: MockErrorPresentationalModelConverter(),
            lastUpdatedTextFormatter: MockLastUpdatedTextFormatter(),
            onSelect: { _ in }
        )

        viewModel.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        guard case .loaded(_, let message) = viewModel.contentState else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(message == MockErrorPresentationalModelConverter().livePriceRefreshResult)
    }

    @Test func selectRoutesByDateFromPresentationRow() {
        let selectedDate = Date()
        let selected = BitcoinHistoryRowPresentationalModel(
            id: "selected",
            date: selectedDate,
            title: "Today",
            subtitle: nil,
            priceText: "EUR 60000"
        )
        var routedDate: Date?
        let viewModel = BitcoinListViewModel(
            getBitcoinHistoryUseCase: MockGetBitcoinHistoryUseCase(result: .success([])),
            observeBitcoinCurrentPriceUseCase: MockObserveBitcoinCurrentPriceUseCase(results: []),
            presentationalModelConverter: MockBitcoinListPresentationalModelConverter(),
            errorPresentationalModelConverter: MockErrorPresentationalModelConverter(),
            lastUpdatedTextFormatter: MockLastUpdatedTextFormatter(),
            onSelect: { routedDate = $0 }
        )

        viewModel.select(selected)

        #expect(routedDate == selectedDate)
    }
}
