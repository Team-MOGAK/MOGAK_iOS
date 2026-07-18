import FSCalendar
import ReusableKit
import SnapKit
import Then
import UIKit

final class JogakFormViewController: UIViewController {
    weak var coordinator: MG2MogakJogakFormCoordinator?
    var onFinish: (() -> Void)?

    private enum Reusable {
        static let selectionChip = ReusableCell<MG2SelectionChipCell>()
    }

    private let mode: MG2JogakFormMode
    private let viewModel: MG2JogakFormViewModel
    private let dateCalendar: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = .current
        calendar.timeZone = .current
        return calendar
    }()
    private var routineCollectionHeightConstraint: NSLayoutConstraint?
    private var hasConfiguredInitialState = false

    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .white
    }
    private let contentView = DismissKeyboardView().then {
        $0.backgroundColor = .white
    }
    private let mogakCategoryTitleLabel = UILabel().then {
        $0.text = "모각 카테고리"
        $0.font = UIFont.pretendard(.semiBold, size: 14)
    }
    private let mogakCategoryView = UIView().then {
        $0.layer.cornerRadius = 8
    }
    private let mogakCategoryLabel = UILabel().then {
        $0.font = UIFont.pretendard(.semiBold, size: 14)
    }
    private let jogakDetailTitleLabel = UILabel().then {
        $0.text = "조각 세부 제목"
        $0.font = UIFont.pretendard(.semiBold, size: 14)
    }
    private let jogakDetailTextField = UITextField().then {
        $0.placeholder = "세부 제목을 적어주세요"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.borderStyle = .none
        $0.leftViewMode = .unlessEditing
    }
    private let jogakDetailUnderLineView = UIView().then {
        $0.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        $0.layer.borderWidth = 1
    }
    private let routineTitleLabel = UILabel().then {
        $0.text = "루틴 설정"
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = UIColor(hex: "24252E")
    }
    private let routineExplanationLabel = UILabel().then {
        $0.text = "일주일에 며칠 반복하는지 선택해 주세요."
        $0.font = UIFont.pretendard(.regular, size: 14)
        $0.textColor = UIColor(hex: "6E707B")
    }
    private lazy var toggleButton = UISwitch().then {
        $0.addTarget(self, action: #selector(toggleSwitchChanged(_:)), for: .valueChanged)
    }
    private let routineRepeatCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: MG2LeftAlignedCollectionViewFlowLayout()
    ).then {
        guard let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        $0.isScrollEnabled = false
        $0.allowsMultipleSelection = true
        $0.backgroundColor = .white
        $0.register(Reusable.selectionChip)
    }
    private let endExplanationLabel = UILabel().then {
        $0.text = "언제까지 반복할까요?"
        $0.font = UIFont.pretendard(.regular, size: 14)
        $0.textColor = UIColor(hex: "6E707B")
    }
    private let endLabel = UILabel().then {
        $0.text = "종료"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.semiBold, size: 14)
    }
    private let endTextField = UITextField().then {
        $0.borderStyle = .line
        $0.layer.borderWidth = 1
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftViewMode = .unlessEditing
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        $0.textColor = UIColor(hex: "475FFD")
        $0.attributedPlaceholder = NSAttributedString(
            string: "yyyy/mm/dd(요일)",
            attributes: [
                .foregroundColor: UIColor(hex: "BFC3D4"),
                .font: UIFont.pretendard(.medium, size: 16)
            ]
        )
    }
    private let calendar = FSCalendar(frame: .zero).then {
        $0.weekdayHeight = 15
        $0.headerHeight = 0
        $0.transitionCoordinator.cachedMonthSize.height = 193
        $0.appearance.weekdayFont = UIFont.pretendard(.regular, size: 12)
        $0.appearance.weekdayTextColor = UIColor(hex: "000000")
        $0.appearance.titleDefaultColor = UIColor(hex: "200E04")
        $0.appearance.titleTodayColor = UIColor(hex: "200E04")
        $0.appearance.titleSelectionColor = .white
        $0.appearance.titleFont = UIFont.pretendard(.medium, size: 16)
        $0.appearance.todayColor = .clear
        $0.appearance.selectionColor = UIColor(hex: "475FFD")
        $0.appearance.borderRadius = 0.2
        $0.locale = Locale(identifier: "ko_KR")
        $0.scope = .month
        $0.isHidden = true
    }
    private let endHeaderTitle = UILabel().then {
        $0.textColor = UIColor(hex: "24252E")
        $0.font = UIFont.pretendard(.semiBold, size: 18)
        $0.isHidden = true
    }
    private lazy var endPreviousButton = UIButton().then {
        $0.tintColor = UIColor(hex: "24252E")
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.addTarget(self, action: #selector(showPreviousMonth), for: .touchUpInside)
        $0.isHidden = true
    }
    private lazy var endNextButton = UIButton().then {
        $0.tintColor = UIColor(hex: "24252E")
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.addTarget(self, action: #selector(showNextMonth), for: .touchUpInside)
        $0.isHidden = true
    }
    private lazy var completeButton = MG2PrimaryActionButton().then {
        $0.setTitle("완료", for: .normal)
        $0.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }

    init(mode: MG2JogakFormMode, viewModel: MG2JogakFormViewModel) {
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
        configureCategory()
        configureJogakTitle()
        configureRoutine()
        configureEndDate()
        configureCompleteButton()
        configureCalendar()
        updateButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasConfiguredInitialState else { return }
        hasConfiguredInitialState = true

        let state = viewModel.state
        toggleButton.isOn = state.isRoutine
        if let endDate = state.endDate {
            endTextField.text = viewModel.displayDate(endDate)
            calendar.select(endDate)
            calendar.setCurrentPage(endDate, animated: false)
            endHeaderTitle.text = viewModel.monthTitle(for: endDate)
        }
        for index in state.selectedRoutineDayIndices {
            routineRepeatCollectionView.selectItem(
                at: IndexPath(item: index, section: 0),
                animated: false,
                scrollPosition: []
            )
        }
        updateRoutineVisibility()
        updateButtonState()
    }

    private func configureInitialValues() {
        let state = viewModel.state
        jogakDetailTextField.text = viewModel.state.title
        mogakCategoryView.backgroundColor = UIColor(hex: state.categoryColor).withAlphaComponent(0.1)
        mogakCategoryLabel.text = state.category
        mogakCategoryLabel.textColor = UIColor(hex: state.categoryColor)
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
            title = "조각 생성"
        case .edit:
            title = "조각 수정"
        }
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.pretendard(.semiBold, size: 18)
        ]
        navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "chevron.left")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")
        navigationController?.navigationBar.tintColor = UIColor(hex: "24252E")
    }

    private func configureCategory() {
        contentView.addSubviews(mogakCategoryTitleLabel, mogakCategoryView, mogakCategoryLabel)
        mogakCategoryTitleLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
        mogakCategoryView.snp.makeConstraints {
            $0.top.equalTo(mogakCategoryTitleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(30)
            $0.width.greaterThanOrEqualTo(57)
        }
        mogakCategoryLabel.snp.makeConstraints {
            $0.centerY.equalTo(mogakCategoryView)
            $0.leading.trailing.equalTo(mogakCategoryView).inset(12)
        }
    }

    private func configureJogakTitle() {
        contentView.addSubviews(jogakDetailTitleLabel, jogakDetailTextField, jogakDetailUnderLineView)
        jogakDetailTextField.delegate = self
        jogakDetailTitleLabel.snp.makeConstraints {
            $0.top.equalTo(mogakCategoryView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        }
        jogakDetailTextField.snp.makeConstraints {
            $0.top.equalTo(jogakDetailTitleLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        jogakDetailUnderLineView.snp.makeConstraints {
            $0.top.equalTo(jogakDetailTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(2)
        }
    }

    private func configureRoutine() {
        contentView.addSubviews(
            routineTitleLabel,
            routineExplanationLabel,
            routineRepeatCollectionView,
            toggleButton
        )
        routineRepeatCollectionView.delegate = self
        routineRepeatCollectionView.dataSource = self
        routineRepeatCollectionView.translatesAutoresizingMaskIntoConstraints = false
        routineCollectionHeightConstraint = routineRepeatCollectionView.heightAnchor.constraint(equalToConstant: 0)
        routineCollectionHeightConstraint?.isActive = true

        routineTitleLabel.snp.makeConstraints {
            $0.top.equalTo(jogakDetailUnderLineView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        }
        toggleButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(routineTitleLabel)
            $0.width.equalTo(60)
            $0.height.equalTo(26)
        }
        routineExplanationLabel.snp.makeConstraints {
            $0.top.equalTo(routineTitleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        routineRepeatCollectionView.snp.makeConstraints {
            $0.top.equalTo(routineExplanationLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-80)
        }
    }

    private func configureEndDate() {
        contentView.addSubviews(endExplanationLabel, endLabel, endTextField)
        contentView.addSubviews(endHeaderTitle, endPreviousButton, endNextButton, calendar)
        endTextField.delegate = self

        endExplanationLabel.snp.makeConstraints {
            $0.top.equalTo(routineRepeatCollectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        endLabel.snp.makeConstraints {
            $0.top.equalTo(endExplanationLabel.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(20)
        }
        endTextField.snp.makeConstraints {
            $0.centerY.equalTo(endLabel)
            $0.leading.equalTo(endLabel.snp.trailing).offset(19)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
        }
        endPreviousButton.snp.makeConstraints {
            $0.top.equalTo(endLabel.snp.bottom).offset(43)
            $0.centerX.equalToSuperview().offset(-60)
            $0.width.height.equalTo(16)
        }
        endHeaderTitle.text = viewModel.monthTitle(for: viewModel.state.currentCalendarPage)
        endHeaderTitle.snp.makeConstraints {
            $0.centerY.equalTo(endPreviousButton)
            $0.leading.equalTo(endPreviousButton.snp.trailing).offset(4)
        }
        endNextButton.snp.makeConstraints {
            $0.centerY.equalTo(endPreviousButton)
            $0.leading.equalTo(endHeaderTitle.snp.trailing).offset(4)
            $0.width.height.equalTo(16)
        }
        calendar.snp.makeConstraints {
            $0.top.equalTo(endHeaderTitle.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(212)
        }
    }

    private func configureCompleteButton() {
        contentView.addSubview(completeButton)
        completeButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(endTextField.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }
    }

    private func configureCalendar() {
        calendar.register(CalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.delegate = self
        calendar.dataSource = self
        calendar.allowsMultipleSelection = false
        calendar.scrollDirection = .horizontal
        calendar.today = nil
        calendar.swipeToChooseGesture.isEnabled = false
        calendar.clipsToBounds = true
    }

    private func updateRoutineVisibility() {
        let isRoutine = viewModel.state.isRoutine
        routineRepeatCollectionView.isHidden = !isRoutine
        endExplanationLabel.isHidden = !isRoutine
        endLabel.isHidden = !isRoutine
        endTextField.isHidden = !isRoutine
        routineCollectionHeightConstraint?.constant = isRoutine ? 110 : 0
        if !isRoutine {
            setCalendarVisible(false)
        }
        view.layoutIfNeeded()
    }

    private func setCalendarVisible(_ isVisible: Bool) {
        [endPreviousButton, endHeaderTitle, endNextButton, calendar].forEach {
            $0.isHidden = !isVisible
        }
        completeButton.snp.remakeConstraints {
            if isVisible {
                $0.top.equalTo(calendar.snp.bottom).offset(50)
            } else {
                $0.top.greaterThanOrEqualTo(endTextField.snp.bottom).offset(40)
            }
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }
        view.layoutIfNeeded()
    }

    private func updateButtonState() {
        completeButton.isEnabled = viewModel.isValid
    }

    @objc private func toggleSwitchChanged(_ sender: UISwitch) {
        viewModel.setRoutine(sender.isOn)
        updateRoutineVisibility()
        updateButtonState()
    }

    @objc private func showNextMonth() {
        moveCalendar(by: 1)
    }

    @objc private func showPreviousMonth() {
        moveCalendar(by: -1)
    }

    private func moveCalendar(by monthOffset: Int) {
        guard let page = viewModel.moveCalendarPage(by: monthOffset) else { return }
        calendar.setCurrentPage(page, animated: true)
        endHeaderTitle.text = viewModel.monthTitle(for: page)
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

extension JogakFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard textField == endTextField else { return true }
        setCalendarVisible(true)
        return false
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == jogakDetailTextField {
            viewModel.updateTitle(textField.text ?? "")
        }
        updateButtonState()
    }
}

extension JogakFormViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.routineDays.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(Reusable.selectionChip, for: indexPath)
        cell.configure(title: viewModel.routineDays[indexPath.item], style: .weekday)
        return cell
    }
}

extension JogakFormViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.setRoutineDay(at: indexPath.item, isSelected: true)
        updateButtonState()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.setRoutineDay(at: indexPath.item, isSelected: false)
        updateButtonState()
    }
}

extension JogakFormViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let text = viewModel.routineDays[indexPath.item] as NSString
        let size = text.size(withAttributes: [.font: UIFont.pretendard(.medium, size: 16)])
        return CGSize(width: size.width + 37, height: size.height + 30)
    }
}

extension JogakFormViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.selectEndDate(date)
        endTextField.text = viewModel.displayDate(date)
        updateButtonState()
    }

    func calendar(
        _ calendar: FSCalendar,
        cellFor date: Date,
        at position: FSCalendarMonthPosition
    ) -> FSCalendarCell {
        calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
    }

    func calendar(
        _ calendar: FSCalendar,
        willDisplay cell: FSCalendarCell,
        for date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {
        configureCell(for: date, at: monthPosition)
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        viewModel.updateCalendarPage(calendar.currentPage)
        endHeaderTitle.text = viewModel.monthTitle(for: calendar.currentPage)
    }

    private func configureCell(for date: Date, at position: FSCalendarMonthPosition) {
        guard let cell = calendar.cell(for: date, at: position) as? CalendarCell else { return }

        var selectionType = SelectionType.none
        if let cellCalendar = cell.calendar,
           cellCalendar.selectedDates.contains(where: { dateCalendar.isDate($0, inSameDayAs: date) }),
           let previousDate = dateCalendar.date(byAdding: .day, value: -1, to: date),
           let nextDate = dateCalendar.date(byAdding: .day, value: 1, to: date) {
            if cellCalendar.selectedDates.contains(previousDate) && cellCalendar.selectedDates.contains(nextDate) {
                selectionType = .middle
            } else if cellCalendar.selectedDates.contains(previousDate) {
                selectionType = .rightBorder
            } else if cellCalendar.selectedDates.contains(nextDate) {
                selectionType = .leftBorder
            } else {
                selectionType = .single
            }
        } else if dateCalendar.isDateInToday(date) {
            selectionType = .today
        }
        cell.selectionType = selectionType
    }
}
