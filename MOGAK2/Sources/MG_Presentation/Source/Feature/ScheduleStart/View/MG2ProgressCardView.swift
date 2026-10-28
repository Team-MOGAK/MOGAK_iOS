import SnapKit
import UIKit

/// 홈 진척 카드: 오늘의 조각 n/m · % · 막대 · 상황 문구, 오른쪽에 모각이.
/// % · 막대 색은 포즈의 `pose-*-deep`, 모두 완료면 `success-bg` 카드.
final class MG2ProgressCardView: UIView {
    var onOpenBoard: (() -> Void)?

    let mascotView: MG2MascotView
    private let mainButton = UIControl()
    private let titleLabel = UILabel()
    private let percentLabel = UILabel()
    private let progressBar = MG2ProgressBarView()
    private let lineLabel = UILabel()
    private var lastDone: Int?

    init(isCompact: Bool) {
        mascotView = MG2MascotView(size: isCompact ? 72 : 84)
        super.init(frame: .zero)
        // 모각이 말풍선이 카드 위로 나오므로 모서리만 둥글리고 자르지 않는다 (clipsToBounds 금지).
        roundCorners(DS.Radius.card)
        // `.md-pcard-title` 17/22 700 한 줄 말줄임. "오늘의 조각 n / m"도 숫자가 바뀌는 자리라 고정폭 숫자.
        titleLabel.apply(.button)
        titleLabel.font = .scaledCapped(UIFont.pretendard(.bold, size: 17).withMonospacedDigits(), relativeTo: .body)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        // `.md-pcard-pct` 22/26 800 고정폭 숫자. 줄지 않는다.
        percentLabel.apply(.metric)
        percentLabel.font = .scaledCapped(UIFont.pretendard(.extraBold, size: 22).withMonospacedDigits(), relativeTo: .title2)
        percentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        percentLabel.setContentHuggingPriority(.required, for: .horizontal)
        lineLabel.apply(.footnote, color: DS.Color.sub)
        lineLabel.lineBreakMode = .byTruncatingTail

        let topRow = UIStackView(arrangedSubviews: [titleLabel, percentLabel])
        topRow.alignment = .firstBaseline
        topRow.spacing = 8
        let stack = UIStackView(arrangedSubviews: [topRow, progressBar, lineLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.isUserInteractionEnabled = false
        progressBar.backgroundColor = DS.Color.tabActive

        addSubviews(mainButton, mascotView)
        mainButton.addSubview(stack)
        mainButton.addTarget(self, action: #selector(mainTapped), for: .touchUpInside)
        mainButton.enablePressFeedback()
        mainButton.isAccessibilityElement = true
        mainButton.accessibilityTraits = .button

        // padding 12 10 12 18 · gap 8
        mainButton.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.trailing.equalTo(mascotView.snp.leading).offset(-8)
        }
        stack.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(DS.Space.cardX)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().inset(12)
        }
        mascotView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(12).priority(.high)
            $0.top.greaterThanOrEqualToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(_ progress: MG2TodayProgress, modalartTitle: String?) {
        let color = progress.isAllDone ? DS.Color.successDeep : (DS.Pose(rawValue: progress.pose.rawValue)?.deep ?? DS.Color.accent)
        UIView.animate(withDuration: lastDone == nil ? 0 : 0.4) {
            self.backgroundColor = progress.isAllDone ? DS.Color.successBg : DS.Color.surface
        }
        // 숫자 전환은 크로스페이드.
        for (label, text) in [(titleLabel, progress.isAllDone ? "오늘 조각 모두 완료!" : "오늘의 조각 \(progress.done) / \(progress.total)"), (percentLabel, "\(progress.percent)%")] where label.text != text {
            UIView.transition(with: label, duration: lastDone == nil ? 0 : 0.25, options: .transitionCrossDissolve) { label.text = text }
        }
        percentLabel.textColor = color
        lineLabel.text = progress.line
        progressBar.setProgress(Double(progress.percent) / 100, color: progress.isAllDone ? DS.Color.success : color, animated: lastDone != nil)
        mascotView.pose = progress.pose
        lastDone = progress.done
        mainButton.accessibilityLabel = "‘\(modalartTitle ?? "모다라트")’ 모다라트 열기, 오늘 \(progress.percent)퍼센트 완료, \(progress.line)"
    }

    @objc private func mainTapped() {
        onOpenBoard?()
    }
}
