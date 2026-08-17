import UIKit
import SnapKit

final class MG2TermsAgreeViewController: UIViewController {
    weak var coordinator: MG2LoginCoordinator?

    private let profileViewModel: MG2ProfileSetupViewModel

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "서비스 이용 동의"
        label.font = UIFont.pretendard(.bold, size: 24)
        return label
    }()

    private lazy var allAgreementButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "checkOff"), for: .normal)
        button.addTarget(self, action: #selector(allAgreementTapped), for: .touchUpInside)
        return button
    }()

    private let allAgreementTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "약관 전체 동의"
        label.textColor = DesignSystemColor.black.value
        label.font = UIFont.pretendard(.semiBold, size: 18)
        return label
    }()

    private let allAgreementDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "서비스 이용을 위해 약관에 모두 동의합니다."
        label.textColor = DesignSystemColor.gray3.value
        label.font = UIFont.pretendard(.medium, size: 14)
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemColor.gray2.value
        return view
    }()

    private lazy var agreementStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 28
        return stackView
    }()

    private var agreementRows = [Int: MG2AgreementRowView]()

    private lazy var nextButton: MG2PrimaryActionButton = {
        let button = MG2PrimaryActionButton()
        button.setTitle("다음", for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    init(profileViewModel: MG2ProfileSetupViewModel) {
        self.profileViewModel = profileViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationBar()
        configureLayout()
        loadConsentItems()
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = .gray
    }

    private func configureLayout() {
        view.addSubviews(
            titleLabel,
            allAgreementButton,
            allAgreementTitleLabel,
            allAgreementDescriptionLabel,
            separatorView,
            agreementStackView,
            nextButton
        )

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        allAgreementButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(20)
        }
        allAgreementTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(allAgreementButton)
            $0.leading.equalTo(allAgreementButton.snp.trailing).offset(12)
        }
        allAgreementDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(allAgreementTitleLabel.snp.bottom).offset(9)
            $0.leading.equalTo(allAgreementTitleLabel)
        }
        separatorView.snp.makeConstraints {
            $0.top.equalTo(allAgreementDescriptionLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        agreementStackView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(26)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(48)
        }
    }

    private func loadConsentItems() {
        showLoading()
        profileViewModel.loadConsentItems { [weak self] result in
            guard let self else { return }
            hideLoading()
            switch result {
            case .success:
                configureAgreementRows()
                renderAgreements()
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    private func configureAgreementRows() {
        agreementStackView.arrangedSubviews.forEach {
            agreementStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        agreementRows.removeAll()

        for selection in profileViewModel.state.agreements.selections {
            let item = selection.item
            let requirement = item.required ? "필수" : "선택"
            let row = MG2AgreementRowView(
                title: "(\(requirement)) \(item.name)",
                showsDetail: false
            )
            row.onToggle = { [weak self] in
                self?.profileViewModel.toggleAgreement(id: item.id)
                self?.renderAgreements()
            }
            agreementRows[item.id] = row
            agreementStackView.addArrangedSubview(row)
        }
    }

    private func renderAgreements() {
        let agreements = profileViewModel.state.agreements
        allAgreementButton.setImage(
            UIImage(named: agreements.hasAcceptedAllTerms ? "checkOn" : "checkOff"),
            for: .normal
        )
        for selection in agreements.selections {
            agreementRows[selection.item.id]?.setChecked(selection.agreed)
        }
        nextButton.isEnabled = agreements.hasAcceptedRequiredTerms
    }

    @objc private func nextButtonTapped() {
        coordinator?.routeToNickname(from: self)
    }

    @objc private func allAgreementTapped() {
        profileViewModel.toggleAllAgreements()
        renderAgreements()
    }
}
