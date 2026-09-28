import Combine
import SnapKit
import Then
import UIKit

final class MG2MyPageEditViewController: UIViewController {
    weak var coordinator: MG2MyPageCoordinator?

    private let viewModel: MG2MyPageEditViewModel
    private var cancellables = Set<AnyCancellable>()

    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = DesignSystemColor.gray2.value.cgColor
    }

    private lazy var profileImagePicker = MG2ProfileImagePickerView(imageIDs: viewModel.profileImageIDs)

    private let nameLabel = UILabel().then {
        $0.textColor = DesignSystemColor.black.value
        $0.font = UIFont.pretendard(.bold, size: 22)
    }

    private let jobLabel = UILabel().then {
        $0.textColor = DesignSystemColor.black.value
        $0.font = UIFont.pretendard(.medium, size: 12)
    }

    private let nicknameRow = MG2SettingsRowControl(title: "닉네임 변경")
    private let jobRow = MG2SettingsRowControl(title: "직무 변경")
    private let logoutRow = MG2SettingsRowControl(title: "로그아웃")
    private let withdrawalRow = MG2SettingsRowControl(title: "회원탈퇴")

    private lazy var settingsStack = UIStackView(arrangedSubviews: [nicknameRow, jobRow, logoutRow, withdrawalRow]).then {
        $0.axis = .vertical
        $0.spacing = 32
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
        view.backgroundColor = .white
        configureLayout()
        configureActions()
        bindProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        configureNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
    }

    private func configureLayout() {
        view.addSubviews(profileImageView, profileImagePicker, nameLabel, jobLabel, settingsStack)

        profileImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(100)
        }
        profileImagePicker.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(MG2ProfileImagePickerView.height)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImagePicker.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(20)
        }
        jobLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(20)
        }
        settingsStack.snp.makeConstraints {
            $0.top.equalTo(jobLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
    }

    private func configureActions() {
        profileImagePicker.onSelection = { [weak self] index in self?.selectProfileImage(at: index) }
        if let index = viewModel.selectedProfileImageIndex {
            profileImagePicker.selectImage(at: index)
        }
        nicknameRow.addTarget(self, action: #selector(nicknameRowTapped), for: .touchUpInside)
        jobRow.addTarget(self, action: #selector(jobRowTapped), for: .touchUpInside)
        logoutRow.addTarget(self, action: #selector(logoutRowTapped), for: .touchUpInside)
        withdrawalRow.addTarget(self, action: #selector(withdrawalRowTapped), for: .touchUpInside)
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = DesignSystemColor.gray6.value
        title = "프로필 수정"
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

    private func selectProfileImage(at index: Int) {
        viewModel.selectProfileImage(at: index) { [weak self] result in
            guard let self, case .failure(let error) = result else { return }
            coordinator?.presentError(error, from: self)
        }
    }

    @objc private func nicknameRowTapped() {
        coordinator?.routeToNicknameEdit(from: self)
    }

    @objc private func jobRowTapped() {
        coordinator?.routeToJobEdit(from: self)
    }

    @objc private func logoutRowTapped() {
        showLoading()
        viewModel.logout { [weak self] result in
            guard let self else { return }
            hideLoading()
            if case .failure(let error) = result {
                coordinator?.presentError(error, from: self)
            }
        }
    }

    @objc private func withdrawalRowTapped() {
        coordinator?.presentWithdrawalConfirmation(onConfirm: { [weak self] in self?.withdraw() }, from: self)
    }

    private func withdraw() {
        showLoading()
        viewModel.withdraw { [weak self] result in
            guard let self else { return }
            hideLoading()
            if case .failure(let error) = result {
                coordinator?.presentError(error, from: self)
            }
        }
    }
}
