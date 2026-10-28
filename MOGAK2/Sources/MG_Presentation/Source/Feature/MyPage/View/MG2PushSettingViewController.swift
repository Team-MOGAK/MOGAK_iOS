import SnapKit
import Then
import UIKit

/// 마이페이지 › 푸시 알림. 매일 조각 알림을 켜고 끄고 시각을 정한다. 하위 화면이라 광고를 넣지 않는다.
final class MG2PushSettingViewController: UIViewController {
    weak var coordinator: MG2MyPageCoordinator?

    private let viewModel: MG2PushSettingViewModel

    private let card = UIView().then {
        $0.backgroundColor = DS.Color.surface
        $0.roundCorners(DS.Radius.card)
    }

    private let reminderLabel = UILabel().then {
        $0.apply(.settingRow)
        $0.numberOfLines = 0
        $0.text = "매일 조각 알림"
    }

    private lazy var reminderSwitch = UISwitch().then {
        $0.onTintColor = DS.Color.accent
        $0.accessibilityLabel = "매일 조각 알림"
        $0.addTarget(self, action: #selector(settingChanged), for: .valueChanged)
    }

    private let timeLabel = UILabel().then {
        $0.apply(.settingRow)
        $0.numberOfLines = 0
        $0.text = "알림 시각"
    }

    /// 알림 시각은 칩으로 고른다 (`Chip`: 알림 시간처럼 여러 값 중 하나).
    private lazy var timeChips: [UIButton] = viewModel.timeOptions.enumerated().map { index, option in
        var configuration = UIButton.Configuration.plain()
        configuration.title = option.title
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = T.footnoteBold.font
            return outgoing
        }
        configuration.titleLineBreakMode = .byTruncatingTail
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14)
        configuration.background.cornerRadius = DS.Size.chip / 2
        let button = UIButton(configuration: configuration)
        button.snp.makeConstraints { $0.height.greaterThanOrEqualTo(DS.Size.chip) }
        button.addAction(UIAction { [weak self] _ in self?.timeSelected(at: index) }, for: .touchUpInside)
        return button
    }

    private let hintLabel = UILabel().then {
        $0.apply(.footnote, color: DS.Color.sub)
        $0.numberOfLines = 0
        $0.text = "정한 시각에 오늘의 조각을 알려 드려요"
    }

    private let deniedLabel = UILabel().then {
        $0.apply(.footnote, color: DS.Color.danger)
        $0.numberOfLines = 0
        $0.text = "기기 설정에서 MOGAK 알림이 꺼져 있어요"
        $0.isHidden = true
    }

    private lazy var openSettingsButton = MG2PrimaryActionButton(style: .soft).then {
        $0.setTitle("기기 설정 열기", for: .normal)
        $0.isHidden = true
        $0.addTarget(self, action: #selector(openSettingsTapped), for: .touchUpInside)
    }

    init(viewModel: MG2PushSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.canvas
        configureLayout()
        render()
        viewModel.load { [weak self] in self?.render() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        title = "푸시 알림"
        applyStepNavigationBar()
    }

    private func configureLayout() {
        // 스위치 · 시각은 그대로 두고, 큰 글자에서는 라벨이 줄을 바꿔 행이 커진다 (최소 56).
        let reminderRow = UIStackView(arrangedSubviews: [reminderLabel, reminderSwitch]).then {
            $0.alignment = .center
            $0.spacing = 12
            $0.snp.makeConstraints { $0.height.greaterThanOrEqualTo(DS.Size.row) }
        }
        reminderLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        reminderSwitch.setContentCompressionResistancePriority(.required, for: .horizontal)
        // 칩은 왼쪽부터 간격 8 (Chip FlowLayout).
        let chipRow = UIStackView(arrangedSubviews: timeChips + [UIView()]).then { $0.spacing = 8 }
        let timeRow = UIStackView(arrangedSubviews: [timeLabel, chipRow]).then {
            $0.axis = .vertical
            $0.spacing = 8
            $0.isLayoutMarginsRelativeArrangement = true
            $0.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
        }
        let rows = UIStackView(arrangedSubviews: [reminderRow, timeRow]).then {
            $0.axis = .vertical
        }

        view.addSubviews(card, hintLabel, deniedLabel, openSettingsButton)
        card.addSubview(rows)
        card.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter)
        }
        rows.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: DS.Space.cardX, bottom: 8, right: DS.Space.cardX)) }
        // 안내 문구는 카드 안 글자 줄에 맞춘다.
        hintLabel.snp.makeConstraints {
            $0.top.equalTo(card.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter + DS.Space.cardX)
        }
        deniedLabel.snp.makeConstraints {
            $0.top.equalTo(hintLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(hintLabel)
        }
        openSettingsButton.snp.makeConstraints {
            $0.top.equalTo(deniedLabel.snp.bottom).offset(10)
            $0.leading.equalTo(hintLabel)
        }
    }

    private func render() {
        reminderSwitch.isOn = viewModel.isOn
        for (index, chip) in timeChips.enumerated() {
            let isSelected = viewModel.selectedTimeIndex == index
            chip.configuration?.baseForegroundColor = isSelected ? DS.Color.surface : DS.Color.ink2
            chip.configuration?.background.backgroundColor = isSelected ? DS.Color.accent : DS.Color.fill
            chip.accessibilityTraits = isSelected ? [.button, .selected] : .button
            chip.isEnabled = viewModel.isOn
            chip.alpha = viewModel.isOn ? 1 : 0.4
        }
        deniedLabel.isHidden = !viewModel.isDenied
        openSettingsButton.isHidden = !viewModel.isDenied
    }

    @objc private func settingChanged() {
        viewModel.update(isOn: reminderSwitch.isOn, time: viewModel.time) { [weak self] in self?.render() }
    }

    private func timeSelected(at index: Int) {
        viewModel.update(isOn: reminderSwitch.isOn, time: viewModel.timeOptions[index].time) { [weak self] in self?.render() }
    }

    @objc private func openSettingsTapped() {
        coordinator?.openSystemSettings(from: self)
    }
}
