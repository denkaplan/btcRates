import SwiftUI
import UIKit

final class BitcoinListCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController
    private let dependencies: AppDependencyContainer

    init(navigationController: UINavigationController, dependencies: AppDependencyContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let viewModel = BitcoinListViewModel(
            getHistoryUseCase: dependencies.getBitcoinHistoryUseCase,
            getCurrentPriceUseCase: dependencies.getBitcoinCurrentPriceUseCase,
            timerFactory: dependencies.timerFactory,
            onSelect: { [weak self] item in
                self?.showDetails(for: item.date)
            }
        )
        let viewController = UIHostingController(rootView: BitcoinListView(viewModel: viewModel))
        viewController.title = "Bitcoin"
        navigationController.setViewControllers([viewController], animated: false)
    }

    private func showDetails(for date: Date) {
        let detailCoordinator = BitcoinDetailCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            date: date,
            onFinish: { [weak self] coordinator in
                self?.free(coordinator)
            }
        )
        store(detailCoordinator)
        detailCoordinator.start()
    }
}
