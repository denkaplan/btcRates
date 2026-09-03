import UIKit

@MainActor
class Coordinator: NSObject {
    private(set) var childCoordinators: [Coordinator] = []

    func start() {
        assertionFailure("Subclasses must override start().")
    }

    func store(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func free(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
