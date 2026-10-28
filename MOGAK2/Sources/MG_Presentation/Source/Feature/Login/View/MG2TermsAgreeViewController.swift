import UIKit
import SnapKit

final class MG2TermsAgreeViewController: UIViewController {
    weak var coordinator: MG2LoginCoordinator?

    private let viewModel: MG2TermsAgreeViewModel

    private let scrollView = UIScrollView()

    private let headerView = MG2ScreenHeaderView(title: "서비스 이용 동의")

    private lazy var allAgreementRow = MG2AgreementRowView(title: "약관 전체 동의", subtitle: "서비스 이용을 위해 약관에 모두 동의해요", isEmphasized: true)

    private lazy var agreementStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private var agreementRows = [Int: MG2AgreementRowView]()

    private lazy var nextButton: MG2PrimaryActionButton = {
        let button = MG2PrimaryActionButton()
        button.setTitle("동의하고 계속하기", for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    init(viewModel: MG2TermsAgreeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface
        configureNavigationBar()
        configureLayout()
        loadConsentItems()
    }

    private func configureNavigationBar() {
        applyStepNavigationBar()
        allAgreementRow.onToggle = { [weak self] in self?.allAgreementButtonTapped() }
    }

    private func configureLayout() {
        // 큰 글자 · 약관이 많을 때 버튼 아래로 깔리지 않도록 스크롤 안에 둔다.
        view.addSubviews(scrollView, nextButton)
        scrollView.addSubviews(headerView, allAgreementRow, agreementStackView)

        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-12)
        }
        scrollView.contentLayoutGuide.snp.makeConstraints {
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(DS.Space.sheet)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
        }
        allAgreementRow.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
        }
        agreementStackView.snp.makeConstraints {
            $0.top.equalTo(allAgreementRow.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter + 16)
            $0.bottom.equalToSuperview().inset(DS.Space.sheet)
        }
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(DS.Size.button)
        }
    }

    private func loadConsentItems() {
        showLoading()
        viewModel.loadConsentItems { [weak self] result in
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

        for selection in viewModel.agreements.selections {
            let item = selection.item
            let requirement = item.required ? "필수" : "선택"
            let row = MG2AgreementRowView(title: "(\(requirement)) \(item.name)")
            row.onToggle = { [weak self] in
                self?.viewModel.toggleAgreement(id: item.id)
                self?.renderAgreements()
            }
            agreementRows[item.id] = row
            agreementStackView.addArrangedSubview(row)
        }
    }

    private func renderAgreements() {
        let agreements = viewModel.agreements
        allAgreementRow.setChecked(agreements.hasAcceptedAllTerms)
        for selection in agreements.selections {
            agreementRows[selection.item.id]?.setChecked(selection.agreed)
        }
        nextButton.isEnabled = agreements.hasAcceptedRequiredTerms
    }

    @objc private func nextButtonTapped() {
        coordinator?.routeToNickname(draft: viewModel.draft, from: self)
    }

    private func allAgreementButtonTapped() {
        viewModel.toggleAllAgreements()
        renderAgreements()
    }
}
