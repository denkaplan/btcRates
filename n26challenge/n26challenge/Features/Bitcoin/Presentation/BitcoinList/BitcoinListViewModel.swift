import Combine
import Foundation

enum BitcoinListRefresh {
    static let historyDaysIncludingToday = 14
    static let currentPriceInterval: TimeInterval = 60
    static let livePriceSubtitle = "Live, refreshes every \(Int(currentPriceInterval)) seconds"
}

@MainActor
final class BitcoinListViewModel: ObservableObject {
    @Published private(set) var currentPriceText = "—"
    @Published private(set) var contentState: State = .loading
    @Published private(set) var lastUpdatedText: String?


    enum State: Equatable {
        case loading
        case loaded(rows: [BitcoinHistoryRowPresentationalModel], message: ErrorPresentationalModel?)
        case failed(ErrorPresentationalModel)
    }

    private let getBitcoinHistoryUseCase: GetBitcoinHistoryUseCase
    private let observeBitcoinCurrentPriceUseCase: ObserveBitcoinCurrentPriceUseCase
    private let presentationalModelConverter: BitcoinListPresentationalModelConverter
    private let errorPresentationalModelConverter: ErrorPresentationalModelConverter
    private let lastUpdatedTextFormatter: LastUpdatedTextFormatter
    private let onSelect: (BitcoinHistoryRowPresentationalModel) -> Void
    private var currentPriceObservationTask: Task<Void, Never>?
    private var historyTask: Task<Void, Never>?

    init(
        getBitcoinHistoryUseCase: GetBitcoinHistoryUseCase,
        observeBitcoinCurrentPriceUseCase: ObserveBitcoinCurrentPriceUseCase,
        presentationalModelConverter: BitcoinListPresentationalModelConverter,
        errorPresentationalModelConverter: ErrorPresentationalModelConverter,
        lastUpdatedTextFormatter: LastUpdatedTextFormatter,
        onSelect: @escaping (BitcoinHistoryRowPresentationalModel) -> Void
    ) {
        self.getBitcoinHistoryUseCase = getBitcoinHistoryUseCase
        self.observeBitcoinCurrentPriceUseCase = observeBitcoinCurrentPriceUseCase
        self.presentationalModelConverter = presentationalModelConverter
        self.errorPresentationalModelConverter = errorPresentationalModelConverter
        self.lastUpdatedTextFormatter = lastUpdatedTextFormatter
        self.onSelect = onSelect
    }

    deinit {
        currentPriceObservationTask?.cancel()
        historyTask?.cancel()
    }

    func onAppear() {
        if contentRows.isEmpty {
            loadHistory()
        }
        guard currentPriceObservationTask == nil else { return }
        observeCurrentPrice()
    }

    func retry() {
        loadHistory()
        restartCurrentPriceObservation()
    }

    func select(_ item: BitcoinHistoryRowPresentationalModel) {
        onSelect(item)
    }

    private func loadHistory() {
        historyTask?.cancel()
        if contentRows.isEmpty {
            contentState = .loading
        }
        historyTask = Task { [weak self] in
            guard let self else { return }
            do {
                let history = try await getBitcoinHistoryUseCase.execute(daysIncludingToday: BitcoinListRefresh.historyDaysIncludingToday)
                guard !Task.isCancelled else { return }
                apply(presentationalModelConverter.convert(history: history))
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                applyHistoryFailure(error)
            }
        }
    }

    private func restartCurrentPriceObservation() {
        currentPriceObservationTask?.cancel()
        currentPriceObservationTask = nil
        observeCurrentPrice()
    }

    private func observeCurrentPrice() {
        let stream = observeBitcoinCurrentPriceUseCase.stream(interval: BitcoinListRefresh.currentPriceInterval)
        currentPriceObservationTask = Task { [weak self] in
            for await result in stream {
                guard !Task.isCancelled else { return }
                guard let self else { return }
                switch result {
                case .success(let price):
                    mergeCurrentPrice(presentationalModelConverter.convert(currentPrice: price))
                    markUpdated()
                case .failure(let error):
                    if contentRows.isEmpty {
                        contentState = .failed(errorPresentationalModelConverter.convert(error))
                    } else {
                        contentState = .loaded(rows: contentRows, message: errorPresentationalModelConverter.livePriceRefreshError())
                    }
                }
            }
        }
    }

    private func apply(_ model: BitcoinListPresentationalModel) {
        currentPriceText = model.currentPriceText
        contentState = .loaded(rows: model.rows, message: nil)
        markUpdated()
    }

    private func applyHistoryFailure(_ error: Error) {
        let message = errorPresentationalModelConverter.convert(error)
        if contentRows.isEmpty {
            contentState = .failed(message)
        } else {
            contentState = .loaded(rows: contentRows, message: message)
        }
    }

    private func mergeCurrentPrice(_ row: BitcoinHistoryRowPresentationalModel) {
        var rows = contentRows
        if let index = rows.firstIndex(where: { $0.id == row.id }) {
            rows[index] = row
        } else {
            rows.append(row)
        }
        rows.sort { $0.date > $1.date }
        currentPriceText = row.priceText
        contentState = .loaded(rows: rows, message: nil)
    }

    private var contentRows: [BitcoinHistoryRowPresentationalModel] {
        guard case .loaded(let rows, _) = contentState else { return [] }
        return rows
    }

    private func markUpdated() {
        lastUpdatedText = lastUpdatedTextFormatter.string(from: Date())
    }
}
