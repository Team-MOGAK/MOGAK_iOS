import UIKit
import SnapKit
import FSCalendar

final class ScheduleStartViewController: UIViewController {
    weak var coordinator: MG2ScheduleStartCoordinator?

    private let viewModel: MG2ScheduleStartViewModel

    private let calendarView: FSCalendar = {
        let calendar = FSCalendar(frame: .zero)
        calendar.backgroundColor = .white
        return calendar
    }()

    private lazy var calendarScopeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "week"), for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(toggleCalendarScope), for: .touchUpInside)
        return button
    }()

    private lazy var previousPageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(showPreviousCalendarPage), for: .touchUpInside)
        return button
    }()

    private lazy var nextPageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.addTarget(self, action: #selector(showNextCalendarPage), for: .touchUpInside)
        return button
    }()

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.text = viewModel.calendarHeader(for: Date())
        label.textAlignment = .center
        return label
    }()

    private let calendarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let motiveLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘도 조금씩 더 나은 내일을 위해, 조각을 시작해 볼까요?"
        label.textColor = UIColor(hex: "6E707B")
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        return label
    }()

    private let emptyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "blankImage"))
        imageView.clipsToBounds = true
        return imageView
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "내 조각이 없어요...\n모다라트를 먼저 생성해 볼까요?"
        label.font = UIFont(name: "Pretendard", size: 16)
        label.textColor = UIColor(hex: "808497")
        label.numberOfLines = 2
        label.setLineSpacing(lineSpacing: 4)
        label.textAlignment = .center
        return label
    }()

    private lazy var createModalartButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 0.883, green: 0.899, blue: 1, alpha: 1)
        button.layer.cornerRadius = 15
        button.setTitle("모다라트 만들러가기", for: .normal)
        button.setTitleColor(DesignSystemColor.signature.value, for: .normal)
        button.titleLabel?.font = DesignSystemFont.medium12L150.value
        button.addTarget(self, action: #selector(showModalartTab), for: .touchUpInside)
        return button
    }()

    private let contentContainerView = UIView()

    private let scheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var addJogakButton: UIButton = {
        let button = UIButton()
        button.setTitle("오늘 할 조각 추가하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = DesignSystemColor.signature.value
        button.titleLabel?.font = DesignSystemFont.semibold18L100.value
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(addDailyJogak), for: .touchUpInside)
        return button
    }()

    private lazy var scheduleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [scheduleTableView, addJogakButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    init(viewModel: MG2ScheduleStartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "F1F3FA")
        motiveLabel.isHidden = true
        configureLayout()
        configureCalendar()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true

        let selectedDate = calendarView.selectedDate ?? viewModel.state.selectedDate
        loadDailyJogaks(date: selectedDate)
        updateAddButtonVisibility(for: selectedDate)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    private func configureLayout() {
        let headerStackView = UIStackView(
            arrangedSubviews: [previousPageButton, headerLabel, nextPageButton]
        )
        headerStackView.axis = .horizontal
        headerStackView.distribution = .equalSpacing

        view.addSubviews(
            calendarContainerView,
            calendarView,
            calendarScopeButton,
            headerStackView,
            contentContainerView,
            emptyImageView,
            emptyStateLabel,
            createModalartButton
        )
        contentContainerView.addSubviews(motiveLabel, scheduleStackView)

        headerLabel.snp.makeConstraints {
            $0.width.equalTo(110)
            $0.height.equalTo(28)
        }
        headerStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(26)
            $0.leading.equalTo(calendarView.collectionView)
        }
        calendarView.snp.makeConstraints {
            $0.top.equalTo(headerStackView.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(250)
        }
        calendarScopeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(headerStackView)
            $0.width.equalTo(49)
            $0.height.equalTo(30)
        }
        calendarContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(calendarView.snp.bottom).offset(8)
        }
        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        motiveLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(calendarView.collectionView)
        }
        scheduleStackView.snp.makeConstraints {
            $0.top.equalTo(motiveLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(calendarView.collectionView)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
        addJogakButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        emptyImageView.snp.makeConstraints {
            $0.bottom.equalTo(emptyStateLabel.snp.top).offset(-20)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(88)
        }
        emptyStateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(30)
        }
        createModalartButton.snp.makeConstraints {
            $0.top.equalTo(emptyStateLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(153)
            $0.height.equalTo(30)
        }
    }

    private func configureCalendar() {
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.select(Date())
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.scope = .week
        calendarView.appearance.headerMinimumDissolvedAlpha = 0
        calendarView.appearance.selectionColor = UIColor(hex: "475FFD")
        calendarView.appearance.borderRadius = 0.4
        calendarView.weekdayHeight = 33
        calendarView.headerHeight = 0
        calendarView.appearance.weekdayFont = UIFont(name: "Pretendard", size: 12)
        calendarView.appearance.titleDefaultColor = UIColor(hex: "200E04")
        calendarView.appearance.titleFont = UIFont(name: "Pretendard", size: 16)
        calendarView.appearance.titleTodayColor = UIColor(hex: "200E04")
        calendarView.appearance.todayColor = .white
        calendarView.appearance.weekdayTextColor = UIColor(hex: "808080")
        calendarView.placeholderType = .none
        calendarView.scrollEnabled = true
        calendarView.scrollDirection = .horizontal
    }

    private func configureTableView() {
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.register(
            MG2DailyJogakCell.self,
            forCellReuseIdentifier: MG2DailyJogakCell.reuseIdentifier
        )
    }

    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = DesignSystemColor.gray6.value.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.font = DesignSystemFont.medium12L150.value
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.numberOfLines = 2
        toastLabel.layer.cornerRadius = 23
        toastLabel.clipsToBounds = true
        view.addSubview(toastLabel)

        toastLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(70)
            $0.width.lessThanOrEqualTo(300)
            $0.height.equalTo(45)
        }

        UIView.animate(withDuration: 3, delay: 0.1, options: .curveEaseOut) {
            toastLabel.alpha = 0
        } completion: { _ in
            toastLabel.removeFromSuperview()
        }
    }

    private func loadDailyJogaks(date: Date) {
        showLoading()
        viewModel.loadDailyJogaks(date: date) { [weak self] result in
            guard let self else { return }
            hideLoading()

            switch result {
            case .success:
                renderDailyJogaks()
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    private func renderDailyJogaks() {
        let isEmpty = viewModel.state.isEmpty
        emptyImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
        createModalartButton.isHidden = !isEmpty
        motiveLabel.isHidden = isEmpty
        scheduleTableView.reloadData()
    }

    private func updateAddButtonVisibility(for date: Date) {
        addJogakButton.isHidden = !viewModel.isToday(date)
    }

    @objc private func toggleCalendarScope() {
        let isShowingMonth = calendarView.scope == .month
        calendarView.setScope(isShowingMonth ? .week : .month, animated: true)
        calendarScopeButton.setImage(
            UIImage(named: isShowingMonth ? "week" : "month"),
            for: .normal
        )
        headerLabel.text = viewModel.calendarHeader(for: calendarView.currentPage)
    }

    @objc private func showModalartTab() {
        coordinator?.routeToModalartTab(from: self)
    }

    @objc private func addDailyJogak() {
        if viewModel.isGuest {
            coordinator?.presentLoginGate(from: self)
            return
        }
        coordinator?.presentJogakSelection(from: self) { [weak self] in
            self?.refreshDailyJogaks()
        }
    }

    @objc private func showNextCalendarPage() {
        moveCalendarPage(by: 1)
    }

    @objc private func showPreviousCalendarPage() {
        moveCalendarPage(by: -1)
    }

    private func moveCalendarPage(by value: Int) {
        guard let page = viewModel.calendarPage(
            from: calendarView.currentPage,
            offset: value,
            isWeekly: calendarView.scope == .week
        ) else { return }

        calendarView.setCurrentPage(page, animated: true)
        headerLabel.text = viewModel.calendarHeader(for: page)
    }

    private func refreshDailyJogaks() {
        loadDailyJogaks(date: calendarView.selectedDate ?? Date())
    }

    private func showJogakOptions(for item: MG2DailyJogakItem) {
        guard !item.isReadOnly, let jogakID = item.jogakID else { return }
        showLoading()
        viewModel.getJogakForEditing(jogakId: jogakID) { [weak self] result in
            guard let self else { return }
            hideLoading()

            switch result {
            case .success(let detail):
                guard let detail else { return }
                coordinator?.presentJogakOptions(
                    title: item.title,
                    jogak: detail,
                    from: self
                )
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }
}

extension ScheduleStartViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(
        _ calendar: FSCalendar,
        boundingRectWillChange bounds: CGRect,
        animated: Bool
    ) {
        calendarView.snp.updateConstraints {
            $0.height.equalTo(bounds.height)
        }
        view.layoutIfNeeded()
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        headerLabel.text = viewModel.calendarHeader(for: calendar.currentPage)
    }

    func calendar(
        _ calendar: FSCalendar,
        didSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {
        loadDailyJogaks(date: date)
        updateAddButtonVisibility(for: date)
    }
}

extension ScheduleStartViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.state.dailyJogaks.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel.state.dailyJogaks.indices.contains(indexPath.row),
              let cell = tableView.cellForRow(at: indexPath) as? MG2DailyJogakCell else {
            return
        }

        let item = viewModel.state.dailyJogaks[indexPath.row]
        guard !item.isReadOnly else { return }
        guard let newValue = viewModel.toggleJogakAchievement(
            at: indexPath.row,
            completion: { [weak self] result in
                guard case .failure(let error) = result, let self else { return }
                scheduleTableView.reloadData()
                coordinator?.presentError(error, from: self)
            }
        ) else { return }

        cell.setCompleted(newValue)
        if newValue {
            showToast(message: "'\(item.title)' \n오늘 조각을 완료하셨군요!")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MG2DailyJogakCell.reuseIdentifier,
            for: indexPath
        ) as? MG2DailyJogakCell else {
            return UITableViewCell()
        }

        let item = viewModel.state.dailyJogaks[indexPath.row]
        cell.configure(title: item.title, isCompleted: item.isAchievement) { [weak self] in
            self?.showJogakOptions(for: item)
        }
        return cell
    }
}
