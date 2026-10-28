import SnapKit
import Then
import UIKit

final class MG2MogakFormViewController: UIViewController {
    weak var coordinator: MG2MogakJogakFormCoordinator?
    var onFinish: (() -> Void)?

    private let viewModel: MG2MogakFormViewModel
    private var hasConfiguredInitialSelection = false

    private let scrollView = UIScrollView().then {
        $0.backgroundColor = DS.Color.surface
        $0.keyboardDismissMode = .interactive
    }
    private let contentView = MG2DismissKeyboardView().then {
        $0.backgroundColor = DS.Color.surface
    }
    private let mogakLabel = MG2FieldLabel("모각 이름")
    private let mogakTextField = MG2TextField().then {
        $0.placeholder = "모각 이름을 적어 주세요"
        $0.accessibilityLabel = "모각 이름"
    }
    private let mogakHintLabel = MG2HintLabel().then {
        $0.show("최대 12자까지 적을 수 있어요")
    }
    private let categoryLabel = MG2FieldLabel("분류")
    private let categoryExplanationLabel = MG2HintLabel().then {
        $0.show("모각의 분류를 골라 주세요")
    }
    private lazy var categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: MG2LeftAlignedCollectionViewFlowLayout()).then {
        guard let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        $0.isScrollEnabled = false
        $0.backgroundColor = DS.Color.surface
        $0.register(MG2SelectionChipCell.self, forCellWithReuseIdentifier: MG2SelectionChipCell.identifier)
    }
    private let customCategoryTextField = MG2TextField().then {
        $0.placeholder = "분류 이름을 적어 주세요"
        $0.accessibilityLabel = "직접 적는 분류 이름"
        $0.isHidden = true
    }
    private let choiceColorLabel = MG2FieldLabel("모각 색")
    private lazy var colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        guard let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.itemSize = CGSize(width: DS.Size.touch, height: DS.Size.touch)
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: DS.Space.sheet)
        layout.scrollDirection = .horizontal
        $0.showsHorizontalScrollIndicator = false
    }
    private lazy var completeButton = MG2PrimaryActionButton().then {
        $0.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }

    init(viewModel: MG2MogakFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface
        completeButton.setTitle(viewModel.mode.isCreate ? "모각 만들기" : "모각 저장", for: .normal)
        configureInitialValues()
        configureView()
        configureNavigationBar()
        configureMogakField()
        configureCategory()
        configureColorPicker()
        configureCompleteButton()
        loadCategories()
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

        if let categoryIndex = viewModel.selectedCategoryIndex {
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
        title = viewModel.mode.isCreate ? "모각 만들기" : "모각 수정"
        applyStepNavigationBar()
    }

    private func configureMogakField() {
        [mogakLabel, mogakTextField, mogakHintLabel].forEach(contentView.addSubview)
        mogakTextField.delegate = self
        mogakLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide).offset(12)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        mogakTextField.snp.makeConstraints {
            $0.top.equalTo(mogakLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        mogakHintLabel.snp.makeConstraints {
            $0.top.equalTo(mogakTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
    }

    private func configureCategory() {
        [categoryLabel, categoryExplanationLabel, categoryCollectionView,
         customCategoryTextField].forEach(contentView.addSubview)
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.tag = 1
        customCategoryTextField.delegate = self

        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(mogakHintLabel.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        categoryExplanationLabel.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(categoryExplanationLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.height.equalTo(160)
        }
        customCategoryTextField.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
    }

    private func configureColorPicker() {
        colorCollectionView.register(MG2ColorSelectionCell.self, forCellWithReuseIdentifier: MG2ColorSelectionCell.identifier)
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.tag = 2
        contentView.addSubviews(choiceColorLabel, colorCollectionView)

        choiceColorLabel.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        colorCollectionView.snp.makeConstraints {
            $0.top.equalTo(choiceColorLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(DS.Space.sheet)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(DS.Size.touch)
        }
    }

    private func configureCompleteButton() {
        contentView.addSubview(completeButton)
        completeButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(colorCollectionView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(DS.Size.button)
        }
    }

    private func loadCategories() {
        showLoading()
        viewModel.loadCategories { [weak self] result in
            guard let self else { return }
            hideLoading()
            switch result {
            case .success:
                categoryCollectionView.reloadData()
                if let index = viewModel.selectedCategoryIndex {
                    categoryCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: [])
                }
                updateCustomCategoryVisibility()
                updateButtonState()
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    private func updateCustomCategoryVisibility() {
        let isCustomCategorySelected = viewModel.isCustomCategorySelected
        customCategoryTextField.isHidden = !isCustomCategorySelected
        choiceColorLabel.snp.remakeConstraints {
            $0.top.equalTo(isCustomCategorySelected ? customCategoryTextField.snp.bottom : categoryCollectionView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        view.layoutIfNeeded()
    }

    private func updateButtonState() {
        completeButton.isEnabled = viewModel.isValid
    }

    @objc private func completeButtonTapped() {
        guard viewModel.isValid else { return }
        showLoading()
        view.isUserInteractionEnabled = false
        viewModel.submit { [weak self] result in
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

extension MG2MogakFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /// 한도를 넘는 글자는 잘라 낸다 (모각 12).
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == mogakTextField, let current = textField.text, let textRange = Range(range, in: current) else { return true }
        return current.replacingCharacters(in: textRange, with: string).count <= MG2MogakFormViewModel.titleLimit
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

extension MG2MogakFormViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.tag == 1 ? viewModel.categories.count : viewModel.colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2SelectionChipCell.identifier, for: indexPath)
            guard let cell = reusableCell as? MG2SelectionChipCell else { return reusableCell }
            cell.configure(title: viewModel.categories[indexPath.item].name, style: .category, selectedColor: DS.Moak.from(hex: viewModel.state.color).deep)
            return cell
        }

        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2ColorSelectionCell.identifier, for: indexPath)
        guard let cell = reusableCell as? MG2ColorSelectionCell else { return reusableCell }
        cell.configure(serverHex: viewModel.colors[indexPath.item], accessibilityName: "모각 색 \(indexPath.item + 1)")
        return cell
    }
}

extension MG2MogakFormViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            viewModel.selectCategory(at: indexPath.item)
            updateCustomCategoryVisibility()
            updateButtonState()
        } else {
            viewModel.selectColor(at: indexPath.item)
            // 고른 분류 칩도 새 모각 색으로.
            let selected = categoryCollectionView.indexPathsForSelectedItems
            categoryCollectionView.reloadData()
            selected?.forEach { categoryCollectionView.selectItem(at: $0, animated: false, scrollPosition: []) }
        }
    }
}

extension MG2MogakFormViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard collectionView.tag == 1 else { return CGSize(width: DS.Size.touch, height: DS.Size.touch) }
        return MG2SelectionChipCell.size(for: viewModel.categories[indexPath.item].name)
    }
}
