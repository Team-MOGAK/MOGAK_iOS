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
        $0.text = "매일 조각 알림"
    }

    private lazy var reminderSwitch = UISwitch().then {
        $0.onTintColor = DS.Color.accent
        $0.accessibilityLabel = "매일 조각 알림"
        $0.addTarget(self, action: #selector(settingChanged), for: .valueChanged)
    }

    private let timeLabel = UILabel().then {
        $0.apply(.settingRow)
        $0.text = "알림 시각"
    }

    private lazy var timePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .compact
        $0.locale = Locale(identifier: "ko_KR")
        $0.minuteInterval = 5
        $0.tintColor = DS.Color.accentDeep
        $0.accessibilityLabel = "알림 시각"
        $0.addTarget(self, action: #selector(settingChanged), for: .valueChanged)
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
        let reminderRow = UIStackView(arrangedSubviews: [reminderLabel, reminderSwitch]).then { $0.alignment = .center }
        let timeRow = UIStackView(arrangedSubviews: [timeLabel, timePicker]).then { $0.alignment = .center }
        let rows = UIStackView(arrangedSubviews: [reminderRow, timeRow]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }
        [reminderRow, timeRow].forEach { $0.snp.makeConstraints { $0.height.greaterThanOrEqualTo(DS.Size.row) } }

        view.addSubviews(card, hintLabel, deniedLabel, openSettingsButton)
        card.addSubview(rows)
        card.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter)
        }
        rows.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: DS.Space.cardX, bottom: 8, right: DS.Space.cardX)) }
        hintLabel.snp.makeConstraints {
            $0.top.equalTo(card.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter + 4)
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
        timePicker.date = Calendar.current.date(from: viewModel.time) ?? Date()
        timePicker.isEnabled = viewModel.isOn
        timePicker.alpha = viewModel.isOn ? 1 : 0.4
        deniedLabel.isHidden = !viewModel.isDenied
        openSettingsButton.isHidden = !viewModel.isDenied
    }

    @objc private func settingChanged() {
        let time = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
        viewModel.update(isOn: reminderSwitch.isOn, time: time) { [weak self] in self?.render() }
    }

    @objc private func openSettingsTapped() {
        coordinator?.openSystemSettings(from: self)
    }
}
