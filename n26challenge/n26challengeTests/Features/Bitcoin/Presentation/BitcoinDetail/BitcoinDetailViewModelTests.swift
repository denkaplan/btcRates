import Foundation
import Testing
@testable import n26challenge

@MainActor
struct BitcoinDetailViewModelTests {
    @Test func initShowsFallbackHistoryPriceWhileLoading() {
        // Arrange
        let initialRow = makeInitialRow()
        let viewModel = BitcoinDetailViewModel(
            initialHistoryRow: initialRow,
            getDetailPriceUseCase: MockGetBitcoinDetailPriceUseCase(result: .success(Price(date: initialRow.date, eur: 60_000))),
            presentationalModelConverter: MockBitcoinDetailPresentationalModelConverter(result: makeFullModel()),
            errorPresentationalModelConverter: MockErrorPresentationalModelConverter()
        )

        // Act
        // Assert
        #expect(viewModel.state == .loading(BitcoinDetailPresentationalModel(
            title: "Fallback title",
            dateText: initialRow.title,
            currencyRows: [BitcoinCurrencyPresentationalModel(currency: .eur, valueText: initialRow.priceText)]
        )))
    }

    @Test func onAppearLoadsFullPresentationModel() async throws {
        // Arrange
        let initialRow = makeInitialRow()
        let expected = makeFullModel()
        let viewModel = BitcoinDetailViewModel(
            initialHistoryRow: initialRow,
            getDetailPriceUseCase: MockGetBitcoinDetailPriceUseCase(result: .success(Price(date: initialRow.date, eur: 60_000, usd: 65_000, gbp: 51_000))),
            presentationalModelConverter: MockBitcoinDetailPresentationalModelConverter(result: expected),
            errorPresentationalModelConverter: MockErrorPresentationalModelConverter()
        )

        // Act
        viewModel.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        #expect(viewModel.state == .loaded(expected, message: nil))
    }

    @Test func onAppearFailureKeepsFallbackDataAndShowsInlineError() async throws {
        // Arrange
        let initialRow = makeInitialRow()
        let errorConverter = MockErrorPresentationalModelConverter()
        let viewModel = BitcoinDetailViewModel(
            initialHistoryRow: initialRow,
            getDetailPriceUseCase: MockGetBitcoinDetailPriceUseCase(result: .failure(NetworkError.timeout)),
            presentationalModelConverter: MockBitcoinDetailPresentationalModelConverter(result: makeFullModel()),
            errorPresentationalModelConverter: errorConverter
        )

        // Act
        viewModel.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        #expect(viewModel.state == .loaded(BitcoinDetailPresentationalModel(
            title: "Fallback title",
            dateText: initialRow.title,
            currencyRows: [BitcoinCurrencyPresentationalModel(currency: .eur, valueText: initialRow.priceText)]
        ), message: errorConverter.result))
    }

    @Test func retryReloadsFullDataAfterFallback() async throws {
        // Arrange
        let initialRow = makeInitialRow()
        let expected = makeFullModel()
        let viewModel = BitcoinDetailViewModel(
            initialHistoryRow: initialRow,
            getDetailPriceUseCase: MockGetBitcoinDetailPriceUseCase(result: .success(Price(date: initialRow.date, eur: 60_000))),
            presentationalModelConverter: MockBitcoinDetailPresentationalModelConverter(result: expected),
            errorPresentationalModelConverter: MockErrorPresentationalModelConverter()
        )

        // Act
        viewModel.retry()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        #expect(viewModel.state == .loaded(expected, message: nil))
    }
}

private func makeInitialRow() -> BitcoinHistoryRowPresentationalModel {
    BitcoinHistoryRowPresentationalModel(
        id: "today",
        date: Date(),
        title: "Today",
        subtitle: nil,
        priceText: "EUR 60000"
    )
}

private func makeFullModel() -> BitcoinDetailPresentationalModel {
    BitcoinDetailPresentationalModel(
        title: "Converted title",
        dateText: "Converted date",
        currencyRows: [BitcoinCurrencyPresentationalModel(currency: .eur, valueText: "EUR 60000")]
    )
}
