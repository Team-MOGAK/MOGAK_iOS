import UIKit

/// 판 → 모각: 누른 칸을 기준으로 확대 (스프링 0.45초). 동작 줄이기면 쓰지 않는다(기본 밀기).
final class MG2BoardZoomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private static let duration: TimeInterval = 0.45

    /// 누른 칸의 창 좌표.
    private let originFrame: CGRect

    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        Self.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to), let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        let container = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        toView.frame = finalFrame
        container.addSubview(toView)

        let origin = container.convert(originFrame, from: nil)
        let scaleX = max(origin.width / max(finalFrame.width, 1), 0.01)
        let scaleY = max(origin.height / max(finalFrame.height, 1), 0.01)
        toView.transform = CGAffineTransform(translationX: origin.midX - finalFrame.midX, y: origin.midY - finalFrame.midY).scaledBy(x: scaleX, y: scaleY)
        toView.alpha = 0
        toView.layer.cornerRadius = DS.Radius.cell
        toView.clipsToBounds = true

        UIView.animate(withDuration: Self.duration, delay: 0, usingSpringWithDamping: 0.86, initialSpringVelocity: 0) {
            toView.transform = .identity
            toView.alpha = 1
            toView.layer.cornerRadius = 0
        } completion: { _ in
            toView.clipsToBounds = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
