import ReusableKit
import SnapKit
import Then
import UIKit

final class MogakFormViewController: UIViewController {
    weak var coordinator: MG2MogakJogakFormCoordinator?
    var onFinish: (() -> Void)?

    private enum Reusable {
        static let selectionChip = ReusableCell<MG2SelectionChipCell>()
    }

    private let mode: MG2MogakFormMode
    private let viewModel: MG2MogakFormViewModel
    private var hasConfiguredInitialSelection = false

    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .white
    }
    private let contentView = DismissKeyboardView().then {
        $0.backgroundColor = .white
    }
    private let mogakLabel = UILabel().then {
        $0.text = "모각 이름"
        $0.font = UIFont.pretendard(.semiBold, size: 14)
    }
    private let mogakTextField = UITextField().then {
        $0.placeholder = "작은 목표의 제목을 입력해주세요."
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.borderStyle = .none
        $0.leftViewMode = .unlessEditing
    }
    private let mogakUnderLineView = UIView().then {
        $0.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        $0.layer.borderWidth = 1
    }
    private let categoryLabel = UILabel().then {
        $0.text = "카테고리"
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = UIColor(hex: "24252E")
    }
    private let categoryExplanationLabel = UILabel().then {
        $0.text = "작은 목표가 속하는 분류를 선택해주세요."
        $0.font = UIFont.pretendard(.regular, size: 14)
        $0.textColor = UIColor(hex: "6E707B")
    }
    private lazy var categoryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: MG2LeftAlignedCollectionViewFlowLayout()
    ).then {
        guard let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 6
        $0.isScrollEnabled = false
        $0.backgroundColor = .white
        $0.register(Reusable.selectionChip)
    }
    private let customCategoryTextField = UITextField().then {
        $0.placeholder = "카테고리 이름을 적어주세요."
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.borderStyle = .none
        $0.leftViewMode = .unlessEditing
        $0.isHidden = true
    }
    private let customCategoryUnderLineView = UIView().then {
        $0.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        $0.layer.borderWidth = 1
        $0.isHidden = true
    }
    private let choiceColorLabel = UILabel().then {
        $0.text = "색상 선택"
        $0.textColor = UIColor(hex: "24252E")
        $0.font = UIFont.pretendard(.semiBold, size: 14)
    }
    private lazy var colorCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        guard let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        $0.showsHorizontalScrollIndicator = false
    }
    private lazy var completeButton = MG2PrimaryActionButton().then {
        $0.setTitle("완료", for: .normal)
        $0.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }

    init(mode: MG2MogakFormMode, viewModel: MG2MogakFormViewModel) {
        self.mode = mode
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureInitialValues()
        configureView()
        configureNavigationBar()
        configureMogakField()
        configureCategory()
        configureColorPicker()
        configureCompleteButton()
        updateButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasConfiguredInitialSelection else { return }
        hasConfiguredInitialSelection = true

        if let categoryIndex = viewModel.categories.firstIndex(
            of: viewModel.state.bigCategory
        ) {
            let indexPath = IndexPath(item: categoryIndex, section: 0)
            categoryCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        if let colorIndex = viewModel.colors.firstIndex(of: viewModel.state.color) {
            let indexPath = IndexPath(item: colorIndex, section: 0)
            colorCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        updateCustomCategoryVisibility()
    }

    private func configureInitialValues() {
        mogakTextField.text = viewModel.state.title
        customCategoryTextField.text = viewModel.state.customCategory
    }

    private func configureView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide)
        }
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.topItem?.title = ""
        switch mode {
        case .create:
            title = "모각 생성"
        case .edit:
            title = "모각 수정"
        }
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.pretendard(.semiBold, size: 18)
        ]
        navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "chevron.left")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")
        navigationController?.navigationBar.tintColor = UIColor(hex: "24252E")
    }

    private func configureMogakField() {
        [mogakLabel, mogakTextField, mogakUnderLineView].forEach(contentView.addSubview)
        mogakTextField.delegate = self
        mogakLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
        mogakTextField.snp.makeConstraints {
            $0.top.equalTo(mogakLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        mogakUnderLineView.snp.makeConstraints {
            $0.top.equalTo(mogakTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(2)
        }
    }

    private func configureCategory() {
        [categoryLabel, categoryExplanationLabel, categoryCollectionView,
         customCategoryTextField, customCategoryUnderLineView].forEach(contentView.addSubview)
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.tag = 1
        customCategoryTextField.delegate = self

        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(mogakUnderLineView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        }
        categoryExplanationLabel.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(categoryExplanationLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(160)
        }
        customCategoryTextField.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        customCategoryUnderLineView.snp.makeConstraints {
            $0.top.equalTo(customCategoryTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(2)
        }
    }

    private func configureColorPicker() {
        colorCollectionView.register(
            MG2ColorSelectionCell.self,
            forCellWithReuseIdentifier: MG2ColorSelectionCell.identifier
        )
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.tag = 2
        contentView.addSubviews(choiceColorLabel, colorCollectionView)

        choiceColorLabel.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        }
        colorCollectionView.snp.makeConstraints {
            $0.top.equalTo(choiceColorLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }

    private func configureCompleteButton() {
        contentView.addSubview(completeButton)
        completeButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(colorCollectionView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-24)
            $0.height.equalTo(52)
        }
    }

    private func updateCustomCategoryVisibility() {
        let isCustomCategorySelected = viewModel.isCustomCategorySelected
        customCategoryTextField.isHidden = !isCustomCategorySelected
        customCategoryUnderLineView.isHidden = !isCustomCategorySelected
        choiceColorLabel.snp.remakeConstraints {
            $0.top.equalTo(
                isCustomCategorySelected
                    ? customCategoryUnderLineView.snp.bottom
                    : categoryCollectionView.snp.bottom
            ).offset(40)
            $0.leading.equalToSuperview().offset(20)
        }
        view.layoutIfNeeded()
    }

    private func updateButtonState() {
        completeButton.isEnabled = viewModel.isValid
    }

    @objc private func completeButtonTapped() {
        showLoading()
        view.isUserInteractionEnabled = false
        viewModel.submit(
            mode: mode
        ) { [weak self] result in
            guard let self else { return }
            hideLoading()
            view.isUserInteractionEnabled = true
            switch result {
            case .success:
                onFinish?()
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }
}

extension MogakFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == mogakTextField {
            viewModel.updateTitle(textField.text ?? "")
        } else if textField == customCategoryTextField {
            viewModel.updateCustomCategory(textField.text)
        }
        updateButtonState()
    }
}

extension MogakFormViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.tag == 1 ? viewModel.categories.count : viewModel.colors.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell = collectionView.dequeue(Reusable.selectionChip, for: indexPath)
            cell.configure(title: viewModel.categories[indexPath.item], style: .category)
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MG2ColorSelectionCell.identifier,
            for: indexPath
        ) as? MG2ColorSelectionCell else {
            return UICollectionViewCell()
        }
        cell.configure(color: UIColor(hex: viewModel.colors[indexPath.item]))
        return cell
    }
}

extension MogakFormViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            viewModel.selectCategory(at: indexPath.item)
            updateCustomCategoryVisibility()
            updateButtonState()
        } else {
            viewModel.selectColor(at: indexPath.item)
        }
    }
}

extension MogakFormViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard collectionView.tag == 1 else {
            return CGSize(width: 40, height: 40)
        }
        let text = viewModel.categories[indexPath.item] as NSString
        let size = text.size(withAttributes: [.font: UIFont.pretendard(.medium, size: 14)])
        return CGSize(width: size.width + 40, height: size.height + 16)
    }
}
