import SnapKit
import UIKit

/// 움직이는 모각이 (`.md-mascot`). 숨쉬기 1.2초(발끝 기준 1.03 × 0.97) · 체크하면 폴짝 0.55초 ·
/// 누르면 반응 포즈와 말풍선 1.5초. 동작 줄이기를 켜면 움직임 없이 포즈만 바뀐다.
final class MG2MascotView: UIControl {
    var pose: MG2MoakPose = .wave {
        didSet { if reaction == nil { render(pose) } }
    }

    var isInteractive = true {
        didSet { render(reaction ?? pose) }
    }

    private let hopView = UIView()
    private let imageView = UIImageView()
    private let bubbleLabel = MG2PaddingLabel(top: 6, bottom: 6, left: 10, right: 10)
    private var reactionIndex = 0
    private var reaction: MG2MoakPose?
    private var reactionWork: DispatchWorkItem?
    private var breathingSize: CGSize = .zero

    init(size: CGFloat) {
        super.init(frame: .zero)
        hopView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFit
        bubbleLabel.font = T.caption1.font
        bubbleLabel.textColor = DS.Color.surface
        bubbleLabel.backgroundColor = DS.Color.ink
        bubbleLabel.layer.cornerRadius = 14
        bubbleLabel.clipsToBounds = true
        bubbleLabel.isHidden = true
        addSubviews(hopView, bubbleLabel)
        hopView.addSubview(imageView)
        snp.makeConstraints { $0.size.equalTo(size) }
        hopView.snp.makeConstraints { $0.edges.equalToSuperview() }
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        bubbleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-20)
            $0.trailing.equalToSuperview().offset(2)
        }
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        enablePressFeedback()
        isAccessibilityElement = true
        render(pose)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView.bounds.size != breathingSize { startBreathing() }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        window == nil ? imageView.layer.removeAllAnimations() : startBreathing()
    }

    /// `mdHop`: 18% 1.1 × 0.86 → 55% 위로 18% · 0.95 × 1.08 → 80% 1.04 × 0.96 → 원래대로.
    func hop() {
        guard !UIAccessibility.isReduceMotionEnabled, hopView.bounds.height > 0 else { return }
        let height = hopView.bounds.height
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.values = [
            CATransform3DIdentity,
            bottomAnchored(scaleX: 1.1, y: 0.86, height: height),
            CATransform3DConcat(bottomAnchored(scaleX: 0.95, y: 1.08, height: height), CATransform3DMakeTranslation(0, -height * 0.18, 0)),
            bottomAnchored(scaleX: 1.04, y: 0.96, height: height),
            CATransform3DIdentity
        ].map { NSValue(caTransform3D: $0) }
        animation.keyTimes = [0, 0.18, 0.55, 0.8, 1]
        animation.duration = 0.55
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.3, 0.7, 0.4, 1)
        hopView.layer.add(animation, forKey: "hop")
    }

    @objc private func tapped() {
        guard isInteractive else { return }
        let next = MG2MoakPose.reactions[reactionIndex % MG2MoakPose.reactions.count]
        reactionIndex += 1
        reaction = next.pose
        render(next.pose)
        bubbleLabel.text = next.bubble
        bubbleLabel.isHidden = false
        if !UIAccessibility.isReduceMotionEnabled {
            bubbleLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            bubbleLabel.alpha = 0
            UIView.animate(withDuration: 0.38, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0) {
                self.bubbleLabel.transform = .identity
                self.bubbleLabel.alpha = 1
            }
        }
        UIAccessibility.post(notification: .announcement, argument: next.bubble)

        reactionWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            reaction = nil
            render(pose)
            bubbleLabel.isHidden = true
        }
        reactionWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
    }

    private func render(_ pose: MG2MoakPose) {
        imageView.image = UIImage(named: DS.Pose(rawValue: pose.rawValue)?.imageName ?? "")
        accessibilityLabel = "모각이"
        accessibilityHint = isInteractive ? "누르면 반응해요" : nil
        accessibilityTraits = isInteractive ? .button : .image
    }

    /// `mdBreathe`: 1.2초마다 1 ↔ 1.03 × 0.97, 발끝 고정.
    private func startBreathing() {
        breathingSize = imageView.bounds.size
        imageView.layer.removeAnimation(forKey: "breathe")
        guard window != nil, !UIAccessibility.isReduceMotionEnabled, breathingSize.height > 0 else { return }
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(caTransform3D: bottomAnchored(scaleX: 1.03, y: 0.97, height: breathingSize.height))
        animation.duration = 1.2
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        imageView.layer.add(animation, forKey: "breathe")
    }

    /// 가운데 기준 크기 변화를 아래쪽 기준으로 옮긴다 (transform-origin: 50% 100%).
    private func bottomAnchored(scaleX: CGFloat, y: CGFloat, height: CGFloat) -> CATransform3D {
        CATransform3DConcat(CATransform3DMakeScale(scaleX, y, 1), CATransform3DMakeTranslation(0, height * (1 - y) / 2, 0))
    }
}
