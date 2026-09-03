import Combine
import Foundation

@MainActor
final class BitcoinListViewModel: ObservableObject {
    @Published private(set) var currentPriceText = "—"
    @Published private(set) var rows: [BitcoinHistoryItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastUpdatedText: String?

    private let repository: BitcoinRepository
    private let timerFactory: TimerFactory
    private let onSelect: (BitcoinHistoryItem) -> Void
    private var pollingTimer: CancellableTimer?
    private var refreshTask: Task<Void, Never>?

    init(
        repository: BitcoinRepository,
        timerFactory: TimerFactory,
        onSelect: @escaping (BitcoinHistoryItem) -> Void
    ) {
        self.repository = repository
        self.timerFactory = timerFactory
        self.onSelect = onSelect
    }

    deinit {
        pollingTimer?.cancel()
        refreshTask?.cancel()
    }

    func onAppear() {
        guard pollingTimer == nil else { return }
        loadHistory()
        startPolling()
    }

    func onDisappear() {
        pollingTimer?.cancel()
        pollingTimer = nil
        refreshTask?.cancel()
    }

    func retry() {
        loadHistory()
    }

    func select(_ item: BitcoinHistoryItem) {
        onSelect(item)
    }

    private func startPolling() {
        let timer = timerFactory.makeTimer(interval: 60) { [weak self] in
            Task { @MainActor in
                self?.refreshCurrentPrice()
            }
        }
        pollingTimer = timer
        timer.start()
    }

    private func loadHistory() {
        refreshTask?.cancel()
        isLoading = rows.isEmpty
        errorMessage = nil
        refreshTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await repository.historicalPrices(daysIncludingToday: 14)
                guard !Task.isCancelled else { return }
                rows = items
                updateCurrentPrice(from: items.first?.eur)
                markUpdated()
                isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    private func refreshCurrentPrice() {
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            guard let self else { return }
            do {
                let price = try await repository.currentPrice()
                guard !Task.isCancelled else { return }
                mergeCurrentPrice(price)
                updateCurrentPrice(from: price.eur)
                markUpdated()
                errorMessage = nil
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = "Could not refresh live price. Pull to retry."
            }
        }
    }

    private func mergeCurrentPrice(_ price: BitcoinPrice) {
        let item = BitcoinHistoryItem(date: price.date, eur: price.eur)
        if let index = rows.firstIndex(where: { Calendar.utc.isDate($0.date, inSameDayAs: price.date) }) {
            rows[index] = item
        } else {
            rows.insert(item, at: 0)
        }
        rows.sort { $0.date > $1.date }
    }

    private func updateCurrentPrice(from price: Decimal?) {
        guard let price else {
            currentPriceText = "—"
            return
        }
        currentPriceText = NumberFormatter.eurCurrency.string(from: price.asNumber) ?? "€\(price)"
    }

    private func markUpdated() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        lastUpdatedText = "Updated " + formatter.string(from: Date())
    }
}
