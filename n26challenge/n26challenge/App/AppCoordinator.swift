import UIKit

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let dependencies: AppDependencyContainer

    init(window: UIWindow, dependencies: AppDependencyContainer) {
        self.window = window
        self.dependencies = dependencies
        self.navigationController = UINavigationController()
        super.init()
    }

    override func start() {
        let bitcoinListCoordinator = BitcoinListCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )
        store(bitcoinListCoordinator)
        bitcoinListCoordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
