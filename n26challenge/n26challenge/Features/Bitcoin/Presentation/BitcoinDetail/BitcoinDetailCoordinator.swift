import SwiftUI
import UIKit

final class BitcoinDetailCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let dependencies: AppDependencyContainer
    private let initialHistoryRow: BitcoinHistoryRowPresentationalModel
    private let onFinish: (BitcoinDetailCoordinator) -> Void
    private weak var viewController: UIViewController?
    private weak var previousNavigationDelegate: UINavigationControllerDelegate?

    init(
        navigationController: UINavigationController,
        dependencies: AppDependencyContainer,
        initialHistoryRow: BitcoinHistoryRowPresentationalModel,
        onFinish: @escaping (BitcoinDetailCoordinator) -> Void
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.initialHistoryRow = initialHistoryRow
        self.onFinish = onFinish
        super.init()
    }

    override func start() {
        let assembly = BitcoinDetailAssembly(dependencies: dependencies, initialHistoryRow: initialHistoryRow)
        let module = assembly.assemble()

        self.viewController = module.view
        previousNavigationDelegate = navigationController.delegate
        navigationController.delegate = self
        navigationController.setNavigationBarHidden(false, animated: true)
        navigationController.pushViewController(module.view, animated: true)
    }

    func finish() {
        if navigationController.delegate === self {
            navigationController.delegate = previousNavigationDelegate
        }
        onFinish(self)
    }
}

// MARK: UINavigationControllerDelegate

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

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard viewController != self.viewController else {
            return
        }
        navigationController.setNavigationBarHidden(true, animated: animated)
    }
}
