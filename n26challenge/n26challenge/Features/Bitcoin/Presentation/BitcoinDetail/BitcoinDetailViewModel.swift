import Combine
import Foundation

@MainActor
final class BitcoinDetailViewModel: ObservableObject {
    @Published private(set) var state: State = .loading

    enum State: Equatable {
        case loading
        case loaded(BitcoinDetailPresentationalModel)
        case failed(String)
    }

    let date: Date
    private let getDetailPriceUseCase: GetBitcoinDetailPriceUseCase
    private let presentationalModelConverter: BitcoinDetailPresentationalModelConverter
    private var loadTask: Task<Void, Never>?

    init(
        date: Date,
        getDetailPriceUseCase: GetBitcoinDetailPriceUseCase,
        presentationalModelConverter: BitcoinDetailPresentationalModelConverter
    ) {
        self.date = date
        self.getDetailPriceUseCase = getDetailPriceUseCase
        self.presentationalModelConverter = presentationalModelConverter
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
        state = .loading
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let price = try await getDetailPriceUseCase.execute(date: date)
                guard !Task.isCancelled else { return }
                state = .loaded(presentationalModelConverter.convert(price: price))
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed(error.localizedDescription)
            }
        }
    }
}
