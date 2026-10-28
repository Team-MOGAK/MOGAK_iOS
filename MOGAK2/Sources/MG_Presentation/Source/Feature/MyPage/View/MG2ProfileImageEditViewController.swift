import SnapKit
import Then
import UIKit

final class MG2ProfileImageEditViewController: UIViewController {
    weak var coordinator: MG2MyPageCoordinator?

    private let viewModel: MG2ProfileImageEditViewModel

    private let headerView = MG2ScreenHeaderView(title: "프로필 이미지 변경", subtitle: "모각러들에게 보여줄 캐릭터를 골라 주세요")

    private let profileImageView = MG2ProfileImageView().then {
        $0.isEditable = true
    }

    private lazy var completeButton = MG2PrimaryActionButton().then {
        $0.setTitle("프로필 이미지 저장", for: .normal)
        $0.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }

    init(viewModel: MG2ProfileImageEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface
        configureNavigationBar()
        configureLayout()
        render()
    }

    private func configureNavigationBar() {
        applyStepNavigationBar()
    }

    private func configureLayout() {
        view.addSubviews(headerView, profileImageView, completeButton)

        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(DS.Space.sheet)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        // 바꿀 이미지는 100pt 원 + 연필 배지.
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
            $0.top.equalTo(headerView.snp.bottom).offset(56)
            $0.centerX.equalToSuperview()
        }
        completeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.height.greaterThanOrEqualTo(DS.Size.button)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        profileImageView.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
    }

    private func render() {
        profileImageView.image = UIImage(named: viewModel.selectedImageName)
        completeButton.isEnabled = viewModel.canSubmit
    }

    @objc private func profileImageTapped() {
        coordinator?.presentProfileImageSelection(imageIDs: viewModel.profileImageIDs, selectedIndex: viewModel.selectedIndex, onSelection: { [weak self] index in
            self?.viewModel.selectImage(at: index)
            self?.render()
        }, from: self)
    }

    @objc private func completeButtonTapped() {
        showLoading()
        viewModel.submit { [weak self] result in
            guard let self else { return }
            hideLoading()
            switch result {
            case .success:
                coordinator?.routeBack(from: self)
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }
}
