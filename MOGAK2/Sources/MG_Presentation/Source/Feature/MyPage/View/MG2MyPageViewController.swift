import Combine
import SnapKit
import Then
import UIKit

final class MG2MyPageViewController: UIViewController {
    weak var coordinator: MG2MyPageCoordinator?

    private let viewModel: MG2MyPageViewModel
    private var cancellables = Set<AnyCancellable>()

    private let scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()

    private let profileView = UIView().then {
        $0.backgroundColor = DS.Color.surface
        $0.roundCorners(DS.Radius.card)
    }

    private let profileImageView = UIImageView().then {
        $0.layer.cornerRadius = 38
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = DS.Color.avatarBg
    }

    private let nameLabel = UILabel().then {
        $0.apply(.title2)
    }

    private let jobLabel = UILabel().then {
        $0.apply(.footnote, color: DS.Color.sub)
    }

    private let settingsCard = UIView().then {
        $0.backgroundColor = DS.Color.surface
        $0.roundCorners(DS.Radius.card)
    }

    private let bannerContainer = UIView()

    private lazy var editButton = Self.makeProfileActionButton(title: "프로필 수정")
    private lazy var shareButton = Self.makeProfileActionButton(title: "프로필 공유")

    private let profileButtonStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .fillEqually
    }

    private let pushRow = MG2SettingsRowControl(title: "푸시 알림 설정")
    private let noticeRow = MG2SettingsRowControl(title: "공지사항")
    private let inquiryRow = MG2SettingsRowControl(title: "문의하기")
    private let termsRow = MG2SettingsRowControl(title: "이용약관")
    private let privacyRow = MG2SettingsRowControl(title: "개인정보 처리방침")
    private let locationRow = MG2SettingsRowControl(title: "위치 서비스 이용동의")
    private lazy var versionRow = MG2SettingsRowControl(title: "버전 정보", detail: viewModel.appVersion)

    private lazy var settingsStack = UIStackView(arrangedSubviews: [pushRow, noticeRow, inquiryRow, termsRow, privacyRow, locationRow, versionRow]).then {
        $0.axis = .vertical
        $0.spacing = 8
    }

    init(viewModel: MG2MyPageViewModel) {
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
        loadProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadBannerIfNeeded()
    }


    private func configureLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(profileView, settingsCard, bannerContainer)
        settingsCard.addSubview(settingsStack)
        profileView.addSubviews(profileImageView, nameLabel, jobLabel, profileButtonStack)
        profileButtonStack.addArrangedSubview(editButton)
        profileButtonStack.addArrangedSubview(shareButton)

        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        profileView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
        }
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(DS.Space.cardX)
            $0.size.equalTo(76)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView).offset(10)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(11)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }
        jobLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nameLabel)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }
        profileButtonStack.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.cardX)
            $0.height.equalTo(DS.Size.chip)
            $0.bottom.equalToSuperview().inset(20)
        }
        settingsCard.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(DS.Space.stack)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
        }
        settingsStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: DS.Space.cardX, bottom: 8, right: DS.Space.cardX)) }
        bannerContainer.snp.makeConstraints {
            $0.top.equalTo(settingsCard.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
            $0.bottom.equalToSuperview().inset(24)
        }
    }

    private func configureActions() {
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        pushRow.addTarget(self, action: #selector(pushRowTapped), for: .touchUpInside)
        noticeRow.addTarget(self, action: #selector(noticeRowTapped), for: .touchUpInside)
        inquiryRow.addTarget(self, action: #selector(inquiryRowTapped), for: .touchUpInside)
        termsRow.addTarget(self, action: #selector(termsRowTapped), for: .touchUpInside)
        privacyRow.addTarget(self, action: #selector(privacyRowTapped), for: .touchUpInside)
        locationRow.addTarget(self, action: #selector(locationRowTapped), for: .touchUpInside)
    }

    private func bindProfile() {
        viewModel.profilePublisher
            .sink { [weak self] state in self?.renderProfile(state) }
            .store(in: &cancellables)
    }

    private func loadProfile() {
        guard !viewModel.isGuest else { return }
        viewModel.fetchUserData { [weak self] result in
            guard case .failure(let error) = result, let self else { return }
            coordinator?.presentError(error, from: self)
        }
    }

    private func renderProfile(_ state: MG2MyPageProfileState) {
        nameLabel.text = state.name
        jobLabel.text = state.job
        profileImageView.image = UIImage(named: state.profileImageName)
    }

    @objc private func editButtonTapped() {
        if viewModel.isGuest {
            coordinator?.presentLoginGate(from: self)
        } else {
            coordinator?.routeToEdit(from: self)
        }
    }

    @objc private func shareButtonTapped() {
        coordinator?.presentUnavailableFeature("프로필 공유 서비스는 준비중이에요", from: self)
    }

    @objc private func pushRowTapped() {
        coordinator?.presentUnavailableFeature("푸시 알림 서비스는 준비중이에요", from: self)
    }

    @objc private func noticeRowTapped() {
        coordinator?.routeToWeb(destination: .notice, from: self)
    }

    @objc private func inquiryRowTapped() {
        coordinator?.routeToWeb(destination: .inquiry, from: self)
    }

    @objc private func termsRowTapped() {
        coordinator?.routeToWeb(destination: .terms, from: self)
    }

    @objc private func privacyRowTapped() {
        coordinator?.routeToWeb(destination: .privacy, from: self)
    }

    @objc private func locationRowTapped() {
        coordinator?.presentUnavailableFeature("위치 서비스 이용동의 서비스는 준비중이에요", from: self)
    }

    private static func makeProfileActionButton(title: String) -> UIButton {
        MG2PrimaryActionButton(style: .soft).then {
            $0.setTitle(title, for: .normal)
        }
    }

    /// 배너는 마이페이지 맨 아래(스크롤 안). 탭 바 옆 고정 배너는 두지 않는다.
    private func loadBannerIfNeeded() {
        guard bannerContainer.subviews.isEmpty, view.bounds.width > 0 else { return }
        guard let banner = coordinator?.makeBanner(width: view.bounds.width - DS.Space.gutter * 2, from: self) else { return }
        bannerContainer.addSubview(banner)
        banner.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
