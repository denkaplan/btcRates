import Combine
import Foundation

@MainActor
final class BitcoinDetailViewModel: ObservableObject {
    @Published private(set) var state: State = .loading

    enum State: Equatable {
        case loading
        case loaded(BitcoinPrice)
        case failed(String)
    }

    let date: Date
    private let repository: BitcoinRepository
    private var loadTask: Task<Void, Never>?

    init(date: Date, repository: BitcoinRepository) {
        self.date = date
        self.repository = repository
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
                let price = try await repository.details(for: date)
                guard !Task.isCancelled else { return }
                state = .loaded(price)
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed(error.localizedDescription)
            }
        }
    }
}
