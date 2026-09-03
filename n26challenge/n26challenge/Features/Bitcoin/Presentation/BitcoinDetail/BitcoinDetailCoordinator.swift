import SwiftUI
import UIKit

final class BitcoinDetailCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController
    private let dependencies: AppDependencyContainer
    private let date: Date
    private let onFinish: (BitcoinDetailCoordinator) -> Void
    private weak var viewController: UIViewController?
    private weak var previousNavigationDelegate: UINavigationControllerDelegate?

    init(
        navigationController: UINavigationController,
        dependencies: AppDependencyContainer,
        date: Date,
        onFinish: @escaping (BitcoinDetailCoordinator) -> Void
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.date = date
        self.onFinish = onFinish
    }

    func start() {
        let viewModel = BitcoinDetailViewModel(
            date: date,
            getDetailPriceUseCase: dependencies.getBitcoinDetailPriceUseCase
        )
        let viewController = UIHostingController(rootView: BitcoinDetailView(viewModel: viewModel))
        viewController.title = DateFormatter.displayDay.string(from: date)
        viewController.navigationItem.largeTitleDisplayMode = .never

        self.viewController = viewController
        previousNavigationDelegate = navigationController.delegate
        navigationController.delegate = self
        navigationController.pushViewController(viewController, animated: true)
    }

    func finish() {
        if navigationController.delegate === self {
            navigationController.delegate = previousNavigationDelegate
        }
        onFinish(self)
    }
}

extension BitcoinDetailCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let coordinatedViewController = self.viewController else { return }
        guard !navigationController.viewControllers.contains(coordinatedViewController) else { return }
        finish()
    }
}
