import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    @discardableResult
    func start() -> UIViewController
}
