import Combine
import SnapKit
import Then
import UIKit

final class MG2MyPageEditViewController: UIViewController {
    weak var coordinator: MG2MyPageCoordinator?

    private let viewModel: MG2MyPageEditViewModel
    private var cancellables = Set<AnyCancellable>()

    // 큰 글자에서 행이 늘어나도 잘리지 않게 스크롤 안에 둔다.
    private let scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()

    private let profileImageView = UIImageView().then {
        $0.layer.cornerRadius = 38
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = DS.Color.avatarBg
    }

    private let nameLabel = UILabel().then {
        $0.apply(.title2)
        $0.lineBreakMode = .byTruncatingTail
    }

    private let jobLabel = UILabel().then {
        $0.apply(.footnote, color: DS.Color.sub)
        $0.lineBreakMode = .byTruncatingTail
    }

    private let accountCard = UIView().then {
        $0.backgroundColor = DS.Color.surface
        $0.roundCorners(DS.Radius.card)
    }

    private let profileImageRow = MG2SettingsRowControl(title: "프로필 이미지 변경")
    private let nicknameRow = MG2SettingsRowControl(title: "닉네임 변경")
    private let jobRow = MG2SettingsRowControl(title: "직무 변경")
    private let logoutRow = MG2SettingsRowControl(title: "로그아웃")
    private let withdrawalRow = MG2SettingsRowControl(title: "회원탈퇴", isDestructive: true)

    private lazy var settingsStack = UIStackView(arrangedSubviews: [profileImageRow, nicknameRow, jobRow]).then {
        $0.axis = .vertical
    }

    private lazy var accountStack = UIStackView(arrangedSubviews: [logoutRow, withdrawalRow]).then {
        $0.axis = .vertical
    }

    private let settingsCard = UIView().then {
        $0.backgroundColor = DS.Color.surface
        $0.roundCorners(DS.Radius.card)
    }

    init(viewModel: MG2MyPageEditViewModel) {
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
        configureActions()
        bindProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        configureNavigationBar()
    }

    private func configureLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(profileImageView, nameLabel, jobLabel, settingsCard, accountCard)
        settingsCard.addSubview(settingsStack)
        accountCard.addSubview(accountStack)

        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(76)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(DS.Space.gutter)
        }
        jobLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(DS.Space.gutter)
        }
        settingsCard.snp.makeConstraints {
            $0.top.equalTo(jobLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
        }
        accountCard.snp.makeConstraints {
            $0.top.equalTo(settingsCard.snp.bottom).offset(DS.Space.stack)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
            $0.bottom.equalToSuperview().inset(24)
        }
        [settingsStack, accountStack].forEach { stack in
            stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: DS.Space.cardX, bottom: 8, right: DS.Space.cardX)) }
        }
    }

    private func configureActions() {
        profileImageRow.addTarget(self, action: #selector(profileImageRowTapped), for: .touchUpInside)
        nicknameRow.addTarget(self, action: #selector(nicknameRowTapped), for: .touchUpInside)
        jobRow.addTarget(self, action: #selector(jobRowTapped), for: .touchUpInside)
        logoutRow.addTarget(self, action: #selector(logoutRowTapped), for: .touchUpInside)
        withdrawalRow.addTarget(self, action: #selector(withdrawalRowTapped), for: .touchUpInside)
    }

    private func configureNavigationBar() {
        title = "프로필 수정"
        applyStepNavigationBar()
    }

    private func bindProfile() {
        viewModel.profilePublisher
            .sink { [weak self] state in
                self?.nameLabel.text = state.name
                self?.jobLabel.text = state.job
                self?.profileImageView.image = UIImage(named: state.profileImageName)
            }
            .store(in: &cancellables)
    }

    @objc private func profileImageRowTapped() {
        coordinator?.routeToProfileImageEdit(from: self)
    }

    @objc private func nicknameRowTapped() {
        coordinator?.routeToNicknameEdit(from: self)
    }

    @objc private func jobRowTapped() {
        coordinator?.routeToJobEdit(from: self)
    }

    @objc private func logoutRowTapped() {
        logoutRow.setLoading(true)
        viewModel.logout { [weak self] result in
            guard let self else { return }
            logoutRow.setLoading(false)
            if case .failure(let error) = result {
                coordinator?.presentError(error, from: self)
            }
        }
    }

    @objc private func withdrawalRowTapped() {
        coordinator?.presentWithdrawalConfirmation(onConfirm: { [weak self] in self?.withdraw() }, from: self)
    }

    private func withdraw() {
        withdrawalRow.setLoading(true)
        viewModel.withdraw { [weak self] result in
            guard let self else { return }
            withdrawalRow.setLoading(false)
            if case .failure(let error) = result {
                coordinator?.presentError(error, from: self)
            }
        }
    }
}
