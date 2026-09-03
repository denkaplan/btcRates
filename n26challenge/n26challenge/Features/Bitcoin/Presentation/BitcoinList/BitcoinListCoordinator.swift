import SwiftUI
import UIKit

final class BitcoinListCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let dependencies: AppDependencyContainer

    init(navigationController: UINavigationController, dependencies: AppDependencyContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        super.init()
    }

    override func start() {
        let assembly = BitcoinListAssembly(dependencies: dependencies) { [weak self] date in
            self?.showDetails(for: date)
        }
        let module = assembly.assemble()
        navigationController.setViewControllers([module.view], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
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
