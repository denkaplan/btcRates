import Combine
import Foundation

@MainActor
final class BitcoinListViewModel: ObservableObject {
    @Published private(set) var currentPriceText = "—"
    @Published private(set) var rows: [BitcoinHistoryRowPresentationalModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastUpdatedText: String?

    private let getBitcoinHistoryUseCase: GetBitcoinHistoryUseCase
    private let observeBitcoinCurrentPriceUseCase: ObserveBitcoinCurrentPriceUseCase
    private let presentationalModelConverter: BitcoinListPresentationalModelConverter
    private let onSelect: (Date) -> Void
    private var currentPriceObservationTask: Task<Void, Never>?
    private var historyTask: Task<Void, Never>?

    init(
        getBitcoinHistoryUseCase: GetBitcoinHistoryUseCase,
        observeBitcoinCurrentPriceUseCase: ObserveBitcoinCurrentPriceUseCase,
        presentationalModelConverter: BitcoinListPresentationalModelConverter,
        onSelect: @escaping (Date) -> Void
    ) {
        self.getBitcoinHistoryUseCase = getBitcoinHistoryUseCase
        self.observeBitcoinCurrentPriceUseCase = observeBitcoinCurrentPriceUseCase
        self.presentationalModelConverter = presentationalModelConverter
        self.onSelect = onSelect
    }

    deinit {
        currentPriceObservationTask?.cancel()
        historyTask?.cancel()
    }

    func onAppear() {
        guard currentPriceObservationTask == nil else { return }
        loadHistory()
        observeCurrentPrice()
    }

    func onDisappear() {
        currentPriceObservationTask?.cancel()
        currentPriceObservationTask = nil
        historyTask?.cancel()
    }

    func retry() {
        loadHistory()
    }

    func select(_ item: BitcoinHistoryRowPresentationalModel) {
        onSelect(item.date)
    }

    private func loadHistory() {
        historyTask?.cancel()
        isLoading = rows.isEmpty
        errorMessage = nil
        historyTask = Task { [weak self] in
            guard let self else { return }
            do {
                apply(presentationalModelConverter.convert(history: try await getBitcoinHistoryUseCase.execute(daysIncludingToday: 14)))
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    private func observeCurrentPrice() {
        currentPriceObservationTask = Task { [weak self] in
            guard let self else { return }
            for await result in observeBitcoinCurrentPriceUseCase.stream(interval: 60) {
                guard !Task.isCancelled else { return }
                switch result {
                case .success(let price):
                    mergeCurrentPrice(presentationalModelConverter.convert(currentPrice: price))
                    markUpdated()
                    errorMessage = nil
                case .failure(let error):
                    errorMessage = rows.isEmpty ? error.localizedDescription : "Could not refresh live price. Pull to retry."
                    isLoading = false
                }
            }
        }
    }

    private func apply(_ model: BitcoinListPresentationalModel) {
        currentPriceText = model.currentPriceText
        rows = model.rows
        markUpdated()
        isLoading = false
    }

    private func mergeCurrentPrice(_ row: BitcoinHistoryRowPresentationalModel) {
        if let index = rows.firstIndex(where: { $0.id == row.id }) {
            rows[index] = row
        } else {
            rows.append(row)
        }
        rows.sort { $0.date > $1.date }
        currentPriceText = row.priceText
    }

    private func markUpdated() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        lastUpdatedText = "Updated " + formatter.string(from: Date())
    }
}
