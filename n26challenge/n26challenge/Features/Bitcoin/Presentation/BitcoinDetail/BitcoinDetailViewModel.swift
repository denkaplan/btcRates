import Combine
import Foundation

@MainActor
final class BitcoinDetailViewModel: ObservableObject {
    @Published private(set) var state: State

    enum State: Equatable {
        case loading(BitcoinDetailPresentationalModel)
        case loaded(BitcoinDetailPresentationalModel, message: ErrorPresentationalModel?)
    }

    private let initialHistoryRow: BitcoinHistoryRowPresentationalModel
    private let getDetailPriceUseCase: GetBitcoinDetailPriceUseCase
    private let presentationalModelConverter: BitcoinDetailPresentationalModelConverter
    private let errorPresentationalModelConverter: ErrorPresentationalModelConverter
    private var loadTask: Task<Void, Never>?

    init(
        initialHistoryRow: BitcoinHistoryRowPresentationalModel,
        getDetailPriceUseCase: GetBitcoinDetailPriceUseCase,
        presentationalModelConverter: BitcoinDetailPresentationalModelConverter,
        errorPresentationalModelConverter: ErrorPresentationalModelConverter
    ) {
        self.initialHistoryRow = initialHistoryRow
        self.getDetailPriceUseCase = getDetailPriceUseCase
        self.presentationalModelConverter = presentationalModelConverter
        self.errorPresentationalModelConverter = errorPresentationalModelConverter
        self.state = .loading(presentationalModelConverter.convert(historyRow: initialHistoryRow))
    }

    deinit {
        loadTask?.cancel()
    }

    func onAppear() {
        load()
    }

    func retry() {
        load()
    }

    private func load() {
        loadTask?.cancel()
        let fallbackModel = presentationalModelConverter.convert(historyRow: initialHistoryRow)
        state = .loading(fallbackModel)
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let price = try await getDetailPriceUseCase.execute(date: initialHistoryRow.date)
                guard !Task.isCancelled else { return }
                state = .loaded(presentationalModelConverter.convert(price: price), message: nil)
            } catch {
                guard !Task.isCancelled else { return }
                state = .loaded(fallbackModel, message: errorPresentationalModelConverter.convert(error))
            }
        }
    }
}
