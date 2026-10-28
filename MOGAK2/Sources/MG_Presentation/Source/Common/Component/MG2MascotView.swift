import SnapKit
import UIKit

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
        // `.md-bubble` 12/16 700 · 안쪽 6 10 · 캡슐, 한 줄.
        bubbleLabel.apply(.caption1, color: DS.Color.surface)
        bubbleLabel.backgroundColor = DS.Color.ink
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
        NotificationCenter.default.addObserver(self, selector: #selector(restartBreathing), name: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil)
        // 백그라운드에 다녀오면 반복 애니메이션이 지워지므로 다시 건다.
        NotificationCenter.default.addObserver(self, selector: #selector(restartBreathing), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleLabel.layer.cornerRadius = bubbleLabel.bounds.height / 2
        if imageView.bounds.size != breathingSize { restartBreathing() }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        restartBreathing()
    }

    /// `mdHop` 0.55초: 눌림 1.1 × 0.86 → 위로 18% · 0.95 × 1.08 → 착지 1.04 × 0.96 → 원래대로.
    func hop() {
        guard !UIAccessibility.isReduceMotionEnabled, hopView.bounds.height > 0 else { return }
        let height = hopView.bounds.height
        UIView.animateKeyframes(withDuration: 0.55, delay: 0, options: [.calculationModeCubic, .allowUserInteraction, .beginFromCurrentState]) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.18) { self.hopView.transform = Self.footAnchored(scaleX: 1.1, y: 0.86, height: height) }
            UIView.addKeyframe(withRelativeStartTime: 0.18, relativeDuration: 0.37) { self.hopView.transform = Self.footAnchored(scaleX: 0.95, y: 1.08, height: height).concatenating(CGAffineTransform(translationX: 0, y: -height * 0.18)) }
            UIView.addKeyframe(withRelativeStartTime: 0.55, relativeDuration: 0.25) { self.hopView.transform = Self.footAnchored(scaleX: 1.04, y: 0.96, height: height) }
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) { self.hopView.transform = .identity }
        }
    }

    @objc private func tapped() {
        guard isInteractive else { return }
        let next = MG2MoakPose.reactions[reactionIndex % MG2MoakPose.reactions.count]
        reactionIndex += 1
        reaction = next.pose
        render(next.pose)
        bubbleLabel.text = next.bubble
        bubbleLabel.isHidden = false
        bubbleLabel.alpha = 1
        bubbleLabel.transform = .identity
        if !UIAccessibility.isReduceMotionEnabled {
            // `mdPop`: 0.6배에서 튕기며 나타난다.
            bubbleLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            bubbleLabel.alpha = 0
            UIView.animate(springDuration: 0.38, bounce: 0.4, initialSpringVelocity: 0, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
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
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.bubbleLabel.alpha = 0
            } completion: { finished in
                if finished { self.bubbleLabel.isHidden = true }
            }
        }
        reactionWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
    }

    private func render(_ pose: MG2MoakPose) {
        let image = UIImage(named: DS.Pose(rawValue: pose.rawValue)?.imageName ?? "")
        if imageView.image != image {
            // 포즈는 0.2초 교차 페이드로 바꾼다 (동작 줄이기에서도 허용되는 전환).
            UIView.transition(with: imageView, duration: 0.2, options: [.transitionCrossDissolve, .allowUserInteraction]) { self.imageView.image = image }
        }
        accessibilityLabel = "모각이"
        accessibilityHint = isInteractive ? "누르면 반응해요" : nil
        accessibilityTraits = isInteractive ? .button : .image
    }

    /// `mdBreathe`: 1.2초마다 1 ↔ 1.03 × 0.97, 발끝 고정. 크기가 바뀌거나 화면에 다시 붙으면 새로 건다.
    @objc private func restartBreathing() {
        breathingSize = imageView.bounds.size
        imageView.layer.removeAllAnimations()
        UIView.performWithoutAnimation { imageView.transform = .identity }
        guard window != nil, !UIAccessibility.isReduceMotionEnabled, breathingSize.height > 0 else { return }
        let squash = Self.footAnchored(scaleX: 1.03, y: 0.97, height: breathingSize.height)
        // 레이아웃이 다른 애니메이션 안에서 불려도 자기 시간 · 곡선을 쓴다.
        UIView.animate(withDuration: 1.2, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut, .allowUserInteraction, .overrideInheritedDuration, .overrideInheritedCurve, .overrideInheritedOptions]) {
            self.imageView.transform = squash
        }
    }

    /// 가운데 기준 크기 변화를 발끝(아래 가운데) 기준으로 옮긴다 (transform-origin: 50% 100%).
    private static func footAnchored(scaleX: CGFloat, y: CGFloat, height: CGFloat) -> CGAffineTransform {
        CGAffineTransform(translationX: 0, y: height * (1 - y) / 2).scaledBy(x: scaleX, y: y)
    }
}
