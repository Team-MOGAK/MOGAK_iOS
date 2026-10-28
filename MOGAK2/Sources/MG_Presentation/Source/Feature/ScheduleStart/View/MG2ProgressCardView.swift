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
        roundCorners(DS.Radius.card)
        titleLabel.apply(.button)
        percentLabel.apply(.metric)
        percentLabel.font = T.metric.font.withMonospacedDigits()
        lineLabel.apply(.footnote, color: DS.Color.sub)
        lineLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        let topRow = UIStackView(arrangedSubviews: [titleLabel, UIView(), percentLabel])
        topRow.alignment = .firstBaseline
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
        titleLabel.text = progress.isAllDone ? "오늘 조각 모두 완료!" : "오늘의 조각 \(progress.done) / \(progress.total)"
        percentLabel.text = "\(progress.percent)%"
        percentLabel.textColor = color
        lineLabel.text = progress.line
        progressBar.setProgress(Double(progress.percent) / 100, color: progress.isAllDone ? DS.Color.success : color, animated: lastDone != nil)
        mascotView.pose = progress.pose
        if let lastDone, progress.done > lastDone { mascotView.hop() }
        lastDone = progress.done
        mainButton.accessibilityLabel = "‘\(modalartTitle ?? "모다라트")’ 모다라트 열기, 오늘 \(progress.percent)퍼센트 완료, \(progress.line)"
    }

    @objc private func mainTapped() {
        onOpenBoard?()
    }
}

extension UIFont {
    /// 숫자가 바뀌는 자리(%, 3/5)는 고정폭 숫자.
    func withMonospacedDigits() -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([.featureSettings: [[UIFontDescriptor.FeatureKey.type: kNumberSpacingType, UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector]]])
        return UIFont(descriptor: descriptor, size: 0)
    }
}
