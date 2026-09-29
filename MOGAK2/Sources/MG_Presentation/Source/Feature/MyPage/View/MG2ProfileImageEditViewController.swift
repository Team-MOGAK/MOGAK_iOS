import SnapKit
import Then
import UIKit

final class MG2ProfileImageEditViewController: UIViewController {
    weak var coordinator: MG2MyPageCoordinator?

    private let viewModel: MG2ProfileImageEditViewModel

    private let titleLabel = UILabel().then {
        $0.text = "프로필 이미지 변경"
        $0.font = UIFont.pretendard(.bold, size: 24)
        $0.textColor = .black
    }

    private let subtitleLabel = UILabel().then {
        $0.text = "모각러들에게 보여줄 이미지를 골라주세요."
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = DesignSystemColor.gray4.value
    }

    private let profileImageView = MG2ProfileImageView().then {
        $0.isEditable = true
    }

    private lazy var completeButton = MG2PrimaryActionButton().then {
        $0.setTitle("완료", for: .normal)
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
        navigationController?.navigationBar.shadowImage = UIImage()
        view.backgroundColor = .white
        configureNavigationBar()
        configureLayout()
        render()
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = .gray
    }

    private func configureLayout() {
        view.addSubviews(titleLabel, subtitleLabel, profileImageView, completeButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
        }
        completeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.06)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
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
