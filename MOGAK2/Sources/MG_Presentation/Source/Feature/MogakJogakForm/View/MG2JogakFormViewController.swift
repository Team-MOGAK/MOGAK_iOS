import SnapKit
import Then
import UIKit

final class MG2JogakFormViewController: UIViewController {
    weak var coordinator: MG2MogakJogakFormCoordinator?
    var onFinish: (() -> Void)?

    private static let weekdayMinimumGap: CGFloat = 4

    private let viewModel: MG2JogakFormViewModel
    private var routineCollectionHeightConstraint: Constraint?

    private let scrollView = UIScrollView().then {
        $0.backgroundColor = DS.Color.surface
        $0.keyboardDismissMode = .interactive
    }
    private let contentView = MG2DismissKeyboardView().then {
        $0.backgroundColor = DS.Color.surface
    }
    private let pathBarView = MG2PathBarView()
    private let jogakDetailTitleLabel = MG2FieldLabel("조각 이름")
    private let jogakDetailTextField = MG2TextField().then {
        $0.placeholder = "오늘 할 조각을 적어 주세요"
        $0.accessibilityLabel = "조각 이름"
    }
    private let routineTitleLabel = MG2FieldLabel("반복")
    private lazy var toggleButton = MG2SegmentedControl(options: ["오늘만", "루틴"]).then {
        $0.accessibilityLabel = "반복"
        $0.addTarget(self, action: #selector(toggleSwitchChanged(_:)), for: .valueChanged)
    }
    private let routineExplanationLabel = MG2HintLabel().then {
        $0.show("루틴은 고른 요일마다 오늘의 조각으로 올라와요")
    }
    // 요일 7개는 기본 흐름 배치로 한 줄을 고르게 채운다.
    private let routineRepeatCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        guard let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = MG2JogakFormViewController.weekdayMinimumGap
        $0.isScrollEnabled = false
        $0.allowsMultipleSelection = true
        $0.backgroundColor = DS.Color.surface
        $0.isHidden = true
        $0.register(MG2SelectionChipCell.self, forCellWithReuseIdentifier: MG2SelectionChipCell.identifier)
    }
    private let endExplanationLabel = MG2HintLabel().then {
        $0.show("언제까지 반복할까요?")
        $0.isHidden = true
    }
    private let endLabel = MG2FieldLabel("끝나는 날").then {
        $0.isHidden = true
    }
    private let endTextField = MG2TextField().then {
        $0.placeholder = "날짜를 골라 주세요"
        $0.font = .scaledCapped(UIFont.pretendard(.semiBold, size: 17).withMonospacedDigits(), relativeTo: .body)
        $0.rightViewMode = .never
        $0.accessibilityLabel = "끝나는 날"
        $0.isHidden = true
    }
    private lazy var endDatePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .wheels
        $0.calendar = Calendar(identifier: .gregorian)
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = .current
        $0.minimumDate = viewModel.minimumEndDate
        $0.tintColor = DS.Color.accent
        $0.isHidden = true
        $0.addTarget(self, action: #selector(endDateChanged(_:)), for: .valueChanged)
    }
    private lazy var completeButton = MG2PrimaryActionButton().then {
        $0.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }

    init(viewModel: MG2JogakFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface
        completeButton.setTitle(viewModel.isCreating ? "조각 만들기" : "조각 저장", for: .normal)
        configureInitialValues()
        configureView()
        configureNavigationBar()
        configurePath()
        configureJogakTitle()
        configureRoutine()
        configureEndDate()
        configureCompleteButton()
        applyInitialState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    private func applyInitialState() {
        let state = viewModel.state
        toggleButton.select(state.isRoutine ? 1 : 0)
        endDatePicker.setDate(state.endDate ?? state.today, animated: false)
        if let endDate = state.endDate {
            endTextField.text = viewModel.displayDate(endDate)
        }
        for index in state.selectedRoutineDayIndices {
            routineRepeatCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: [])
        }
        updateRoutineVisibility()
        updateButtonState()
    }

    private func configureInitialValues() {
        let state = viewModel.state
        jogakDetailTextField.text = state.title
        pathBarView.configure(viewModel.path)
    }

    private func configureView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide)
            $0.height.equalTo(scrollView.frameLayoutGuide).priority(.low)
        }
    }

    private func configureNavigationBar() {
        title = viewModel.isCreating ? "조각 만들기" : "조각 수정"
        applyStepNavigationBar()
    }

    /// 판 › 모각 › 조각 n/8. 어느 모각에 만드는지 알려 준다.
    private func configurePath() {
        contentView.addSubview(pathBarView)
        pathBarView.snp.makeConstraints {
            // `.md-sheet` 안쪽 위 16 · 옆 20 · 아래 20.
            $0.top.equalTo(contentView.safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().inset(DS.Space.sheet)
            $0.trailing.lessThanOrEqualToSuperview().inset(DS.Space.sheet)
        }
    }

    private func configureJogakTitle() {
        contentView.addSubviews(jogakDetailTitleLabel, jogakDetailTextField)
        jogakDetailTextField.delegate = self
        // 칸 사이 28, 칸 안(라벨 · 필드 · 안내) 8.
        jogakDetailTitleLabel.snp.makeConstraints {
            $0.top.equalTo(pathBarView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        jogakDetailTextField.snp.makeConstraints {
            $0.top.equalTo(jogakDetailTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
    }

    private func configureRoutine() {
        contentView.addSubviews(routineTitleLabel, routineExplanationLabel, routineRepeatCollectionView, toggleButton)
        routineRepeatCollectionView.delegate = self
        routineRepeatCollectionView.dataSource = self

        routineTitleLabel.snp.makeConstraints {
            $0.top.equalTo(jogakDetailTextField.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        toggleButton.snp.makeConstraints {
            $0.top.equalTo(routineTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        routineExplanationLabel.snp.makeConstraints {
            $0.top.equalTo(toggleButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        routineRepeatCollectionView.snp.makeConstraints {
            $0.top.equalTo(routineExplanationLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            routineCollectionHeightConstraint = $0.height.equalTo(0).constraint
        }
    }

    private func configureEndDate() {
        contentView.addSubviews(endExplanationLabel, endLabel, endTextField)
        contentView.addSubview(endDatePicker)
        endTextField.delegate = self

        endExplanationLabel.snp.makeConstraints {
            $0.top.equalTo(endLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        endLabel.snp.makeConstraints {
            $0.top.equalTo(routineRepeatCollectionView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        endTextField.snp.makeConstraints {
            $0.top.equalTo(endExplanationLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        endDatePicker.snp.makeConstraints {
            $0.top.equalTo(endTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.height.equalTo(216)
        }
    }

    private func configureCompleteButton() {
        contentView.addSubview(completeButton)
        layoutCompleteButton()
    }

    /// 보이는 마지막 칸 아래 28. 숨긴 칸이 자리를 차지하지 않게 기준을 바꾼다.
    private func layoutCompleteButton() {
        let lastVisibleView: UIView = !endDatePicker.isHidden ? endDatePicker : viewModel.state.isRoutine ? endTextField : routineExplanationLabel
        completeButton.snp.remakeConstraints {
            $0.top.greaterThanOrEqualTo(lastVisibleView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.bottom.equalToSuperview().offset(-DS.Space.sheet)
            $0.height.greaterThanOrEqualTo(DS.Size.button)
        }
    }

    private func updateRoutineVisibility() {
        let isRoutine = viewModel.state.isRoutine
        routineRepeatCollectionView.isHidden = !isRoutine
        endExplanationLabel.isHidden = !isRoutine
        endLabel.isHidden = !isRoutine
        endTextField.isHidden = !isRoutine
        routineCollectionHeightConstraint?.update(offset: isRoutine ? DS.Size.touch : 0)
        if !isRoutine {
            endDatePicker.isHidden = true
        }
        layoutCompleteButton()
        view.layoutIfNeeded()
    }

    private func showEndDatePicker() {
        endDatePicker.isHidden = false
        layoutCompleteButton()
        view.layoutIfNeeded()
        // 펼친 휠이 화면 밖에 있으면 보이게 올린다.
        scrollView.scrollRectToVisible(endDatePicker.convert(endDatePicker.bounds, to: scrollView), animated: !UIAccessibility.isReduceMotionEnabled)
    }

    private func updateButtonState() {
        completeButton.isEnabled = viewModel.isValid
    }

    @objc private func toggleSwitchChanged(_ sender: MG2SegmentedControl) {
        viewModel.setRoutine(sender.selectedIndex == 1)
        updateRoutineVisibility()
        updateButtonState()
    }

    @objc private func endDateChanged(_ sender: UIDatePicker) {
        viewModel.selectEndDate(sender.date)
        endTextField.text = viewModel.displayDate(sender.date)
        updateButtonState()
    }

    @objc private func completeButtonTapped() {
        guard viewModel.isValid else { return }
        completeButton.setLoading(true)
        view.isUserInteractionEnabled = false
        viewModel.submit { [weak self] result in
            guard let self else { return }
            completeButton.setLoading(false)
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

extension MG2JogakFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard textField == endTextField else { return true }
        showEndDatePicker()
        return false
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == jogakDetailTextField {
            viewModel.updateTitle(textField.text ?? "")
        }
        updateButtonState()
    }
}

extension MG2JogakFormViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.routineDays.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2SelectionChipCell.identifier, for: indexPath)
        guard let cell = reusableCell as? MG2SelectionChipCell else { return reusableCell }
        cell.configure(title: viewModel.routineDays[indexPath.item], style: .weekday, selectedColor: DS.Moak.from(hex: viewModel.state.categoryColor).deep)
        return cell
    }
}

extension MG2JogakFormViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.setRoutineDay(at: indexPath.item, isSelected: true)
        updateButtonState()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.setRoutineDay(at: indexPath.item, isSelected: false)
        updateButtonState()
    }
}

extension MG2JogakFormViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 루틴 요일은 원형 칩 44 (터치 영역 최소 크기). 375pt 폭(안쪽 335)에서도 7개가 한 줄에 들어간다.
        let side = min(DS.Size.touch, floor((collectionView.bounds.width - Self.weekdayMinimumGap * 6) / 7))
        return CGSize(width: side, height: side)
    }
}
