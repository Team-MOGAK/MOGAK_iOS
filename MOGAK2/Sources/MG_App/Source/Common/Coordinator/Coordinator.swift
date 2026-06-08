import UIKit
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    @discardableResult
    @MainActor
    func start() -> UIViewController
}
