import UIKit
protocol MG2PresentationCoordinator {
    @MainActor
    func start() -> UIViewController
}
