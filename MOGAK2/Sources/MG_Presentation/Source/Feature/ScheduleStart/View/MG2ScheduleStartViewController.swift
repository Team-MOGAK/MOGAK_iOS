import Combine
import FSCalendar
import SnapKit
import UIKit

/// 조각시작(홈): 주간 달력 · 진척 카드 · 오늘의 조각 · 조각 더 가져오기 · 목록 끝 네이티브 광고.
final class MG2ScheduleStartViewController: UIViewController {
    weak var coordinator: MG2ScheduleStartCoordinator?

    private let viewModel: MG2ScheduleStartViewModel
    private var cancellables = Set<AnyCancellable>()

    private let calendarView: FSCalendar = {
        let calendar = FSCalendar(frame: .zero)
        calendar.backgroundColor = .clear
        return calendar
    }()

    private lazy var calendarScopeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "week"), for: .normal)
        button.accessibilityLabel = "달력 펼치기"
        button.addTarget(self, action: #selector(calendarScopeButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var previousPageButton = makeChevronButton(symbol: "chevron.left", label: "이전", action: #selector(previousPageButtonTapped))
    private lazy var nextPageButton = makeChevronButton(symbol: "chevron.right", label: "다음", action: #selector(nextPageButtonTapped))

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.apply(.title2)
        label.font = T.title2.font.withMonospacedDigits()
        label.text = viewModel.calendarHeader(for: Date())
        label.accessibilityTraits = .header
        return label
    }()

    private let calendarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = DS.Color.surface
        view.roundCorners(DS.Radius.card)
        return view
    }()

    private let progressCardView = MG2ProgressCardView(isCompact: false)

    private let emptyView: UIStackView = {
        let mascot = MG2MascotView(size: 88)
        mascot.pose = .wave
        let title = UILabel()
        title.apply(.title2)
        title.text = "오늘의 조각이 없어요"
        let sub = UILabel()
        sub.apply(.paragraph, color: DS.Color.sub)
        sub.text = "모다라트에서 오늘 할 조각을 가져와 볼까요?"
        sub.numberOfLines = 0
        sub.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [mascot, title, sub])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private lazy var openModalartButton: MG2PrimaryActionButton = {
        let button = MG2PrimaryActionButton(style: .soft)
        button.setTitle("모다라트로 가기", for: .normal)
        button.addTarget(self, action: #selector(createModalartButtonTapped), for: .touchUpInside)
        return button
    }()

    private let scheduleTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        return tableView
    }()

    private lazy var addJogakButton: MG2PrimaryActionButton = {
        let button = MG2PrimaryActionButton(style: .dashed)
        button.setTitle("+ 모다라트에서 조각 더 가져오기", for: .normal)
        button.addTarget(self, action: #selector(addJogakButtonTapped), for: .touchUpInside)
        return button
    }()

    private let nativeAdContainer = UIView()
    /// 네이티브 광고 60초 새로 고침. 화면이 보일 때만 돈다.
    private static let nativeAdRefreshInterval: TimeInterval = 60
    private var nativeAdRefreshTimer: Timer?
    private let headerContainer = UIView()
    private let footerContainer = UIView()

    init(viewModel: MG2ScheduleStartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.canvas
        configureLayout()
        configureCalendar()
        configureTableView()
        progressCardView.onOpenBoard = { [weak self] in self?.createModalartButtonTapped() }
        viewModel.externalChanges
            .sink { [weak self] in self?.refreshJogakOccurrences() }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true

        let selectedDate = calendarView.selectedDate ?? viewModel.state.selectedDate
        loadJogakOccurrences(date: selectedDate)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nativeAdRefreshTimer?.invalidate()
        nativeAdRefreshTimer = Timer.scheduledTimer(withTimeInterval: Self.nativeAdRefreshInterval, repeats: true) { [weak self] _ in
            self?.refreshNativeAd()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nativeAdRefreshTimer?.invalidate()
        nativeAdRefreshTimer = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeTableAccessory(headerContainer) { scheduleTableView.tableHeaderView = $0 }
        sizeTableAccessory(footerContainer) { scheduleTableView.tableFooterView = $0 }
    }

    private func configureLayout() {
        let headerStackView = UIStackView(arrangedSubviews: [previousPageButton, headerLabel, nextPageButton, UIView(), calendarScopeButton])
        headerStackView.alignment = .center
        headerStackView.spacing = 4

        view.addSubviews(headerStackView, calendarContainerView, scheduleTableView, emptyView)
        calendarContainerView.addSubview(calendarView)
        headerContainer.addSubview(progressCardView)

        let footerStack = UIStackView(arrangedSubviews: [addJogakButton, openModalartButton, nativeAdContainer])
        footerStack.axis = .vertical
        footerStack.spacing = DS.Space.stack
        footerStack.setCustomSpacing(24, after: addJogakButton)
        footerContainer.addSubview(footerStack)

        headerStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter)
            $0.height.equalTo(DS.Size.touch)
        }
        [previousPageButton, nextPageButton].forEach { $0.snp.makeConstraints { $0.size.equalTo(DS.Size.touch) } }
        calendarScopeButton.snp.makeConstraints {
            $0.width.equalTo(49)
            $0.height.equalTo(DS.Size.touch)
        }
        calendarContainerView.snp.makeConstraints {
            $0.top.equalTo(headerStackView.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter)
        }
        calendarView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 8, right: 8))
            $0.height.equalTo(90)
        }
        scheduleTableView.snp.makeConstraints {
            $0.top.equalTo(calendarContainerView.snp.bottom).offset(DS.Space.stack)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        emptyView.snp.makeConstraints {
            $0.top.equalTo(scheduleTableView).offset(32)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter * 2)
        }
        progressCardView.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: DS.Space.stack, right: 0)) }
        footerStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)) }
        addJogakButton.snp.makeConstraints { $0.height.equalTo(DS.Size.button) }
        openModalartButton.snp.makeConstraints { $0.height.equalTo(DS.Size.chip) }
    }

    private func configureCalendar() {
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.select(Date())
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.scope = .week
        calendarView.appearance.headerMinimumDissolvedAlpha = 0
        calendarView.appearance.selectionColor = DS.Color.accent
        calendarView.appearance.titleSelectionColor = DS.Color.surface
        calendarView.appearance.borderRadius = 0.4
        calendarView.weekdayHeight = 28
        calendarView.headerHeight = 0
        calendarView.appearance.weekdayFont = T.caption1.font
        calendarView.appearance.weekdayTextColor = DS.Color.muted
        calendarView.appearance.titleFont = T.subhead.font
        calendarView.appearance.titleDefaultColor = DS.Color.ink
        calendarView.appearance.titleTodayColor = DS.Color.accentDeep
        calendarView.appearance.todayColor = DS.Color.accentSoft
        calendarView.placeholderType = .none
        calendarView.scrollEnabled = true
        calendarView.scrollDirection = .horizontal
    }

    private func configureTableView() {
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.register(MG2JogakOccurrenceCell.self, forCellReuseIdentifier: MG2JogakOccurrenceCell.reuseIdentifier)
    }

    private func loadJogakOccurrences(date: Date) {
        showLoading()
        viewModel.loadJogakOccurrences(date: date) { [weak self] result in
            guard let self else { return }
            hideLoading()

            switch result {
            case .success:
                renderOccurrences()
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    private func renderOccurrences() {
        let state = viewModel.state
        let isToday = viewModel.isSelectedDateToday
        emptyView.isHidden = !state.isEmpty
        openModalartButton.isHidden = !state.isEmpty
        addJogakButton.isHidden = !isToday
        renderProgress()
        scheduleTableView.reloadData()
        loadNativeAdIfNeeded()
        view.setNeedsLayout()
    }

    private func renderProgress() {
        if let progress = viewModel.state.progress, progress.total > 0 {
            progressCardView.render(progress, modalartTitle: nil)
            progressCardView.isHidden = false
        } else {
            progressCardView.isHidden = true
        }
        view.setNeedsLayout()
    }

    /// 네이티브 광고는 홈 목록 맨 끝 1개. 못 불러오면 자리째 숨긴다.
    private func loadNativeAdIfNeeded() {
        guard viewModel.canShowNativeAd else {
            nativeAdContainer.isHidden = true
            return
        }
        nativeAdContainer.isHidden = false
        guard nativeAdContainer.subviews.isEmpty else { return }
        refreshNativeAd()
    }

    /// 새 광고로 바꾼다. 처음에 못 불러오면 자리째 숨기고, 새로 고침이 실패하면 지금 광고를 그대로 둔다.
    private func refreshNativeAd() {
        guard viewModel.canShowNativeAd else { return }
        coordinator?.loadNativeAd(from: self) { [weak self] adView in
            guard let self else { return }
            guard let adView else {
                if nativeAdContainer.subviews.isEmpty { nativeAdContainer.isHidden = true }
                return
            }
            nativeAdContainer.subviews.forEach { $0.removeFromSuperview() }
            nativeAdContainer.isHidden = false
            nativeAdContainer.addSubview(adView)
            adView.snp.makeConstraints { $0.edges.equalToSuperview() }
            view.setNeedsLayout()
        }
    }

    /// 테이블 머리 · 꼬리 뷰는 오토레이아웃 높이로 다시 맞춰 넣어야 한다.
    private func sizeTableAccessory(_ accessory: UIView, assign: (UIView) -> Void) {
        let width = scheduleTableView.bounds.width
        guard width > 0 else { return }
        let isHeaderHidden = accessory === headerContainer && progressCardView.isHidden
        let height = isHeaderHidden ? 0 : accessory.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        guard accessory.frame.size != CGSize(width: width, height: height) else { return }
        accessory.frame = CGRect(x: 0, y: 0, width: width, height: height)
        assign(accessory)
    }

    private func makeChevronButton(symbol: String, label: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)), for: .normal)
        button.tintColor = DS.Color.ink
        button.accessibilityLabel = label
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func calendarScopeButtonTapped() {
        let isShowingMonth = calendarView.scope == .month
        calendarView.setScope(isShowingMonth ? .week : .month, animated: true)
        calendarScopeButton.setImage(UIImage(named: isShowingMonth ? "week" : "month"), for: .normal)
        calendarScopeButton.accessibilityLabel = isShowingMonth ? "달력 펼치기" : "달력 접기"
        headerLabel.text = viewModel.calendarHeader(for: calendarView.currentPage)
    }

    @objc private func createModalartButtonTapped() {
        coordinator?.routeToModalartTab(from: self)
    }

    @objc private func addJogakButtonTapped() {
        if viewModel.isGuest {
            coordinator?.presentLoginGate(from: self)
            return
        }
        coordinator?.presentJogakSelection(scheduledDate: viewModel.state.selectedDate, from: self) { [weak self] in self?.refreshJogakOccurrences() }
    }

    @objc private func nextPageButtonTapped() {
        moveCalendarPage(by: 1)
    }

    @objc private func previousPageButtonTapped() {
        moveCalendarPage(by: -1)
    }

    private func moveCalendarPage(by value: Int) {
        guard let page = viewModel.calendarPage(from: calendarView.currentPage, offset: value, isWeekly: calendarView.scope == .week) else { return }

        calendarView.setCurrentPage(page, animated: true)
        headerLabel.text = viewModel.calendarHeader(for: page)
    }

    private func refreshJogakOccurrences() {
        loadJogakOccurrences(date: calendarView.selectedDate ?? Date())
    }

    private func toggleJogak(at indexPath: IndexPath) {
        guard viewModel.state.occurrences.indices.contains(indexPath.row) else { return }
        let item = viewModel.state.occurrences[indexPath.row]
        let outcome = viewModel.toggleJogakCompletion(at: indexPath.row) { [weak self] result in self?.handleJogakCompletionResult(result) }
        let cell = scheduleTableView.cellForRow(at: indexPath) as? MG2JogakOccurrenceCell

        switch outcome {
        case .toggled(let isCompleted, let remaining):
            cell?.setCompleted(isCompleted, animated: true)
            if isCompleted {
                progressCardView.mascotView.hop()
                MG2ToastView.show(in: view, title: "‘\(item.title)’ 완료", subtitle: remaining > 0 ? "한 걸음 더 · 남은 \(remaining)개" : nil)
            }
        case .completedAll:
            cell?.setCompleted(true, animated: true)
            progressCardView.mascotView.hop()
            presentCelebration()
        case .readOnly:
            MG2ToastView.show(in: view, title: "지난 날 기록은 볼 수만 있어요")
        case .rewardRequired:
            coordinator?.presentRewardedUnlock(from: self) { [weak self] in
                self?.viewModel.unlockSelectedDay()
                self?.toggleJogak(at: indexPath)
            }
        case nil:
            break
        }
    }

    /// 확인 → 처음 한 번은 알림 권유, 그 뒤로는 전면 광고 규칙 확인.
    private func presentCelebration() {
        let done = viewModel.state.occurrences.count
        coordinator?.presentCelebration(done: done, completedCount: viewModel.completedPieceCount, from: self) { [weak self] in
            guard let self else { return }
            if viewModel.shouldOfferReminder {
                coordinator?.presentReminderOffer(from: self, onAccept: { [weak self] in self?.viewModel.enableReminder() }, onDecline: { [weak self] in self?.viewModel.declineReminder() })
            } else if viewModel.canShowInterstitial {
                coordinator?.presentInterstitial(from: self) { [weak self] shown in if shown { self?.viewModel.didShowInterstitial() } }
            }
        }
    }

    private func handleJogakCompletionResult(_ result: Result<Void, Error>) {
        renderProgress()
        guard case .failure(let error) = result else { return }
        scheduleTableView.reloadData()
        coordinator?.presentError(error, from: self)
    }

    private func showJogakOptions(for item: MG2JogakOccurrenceItem) {
        coordinator?.presentJogakOptions(title: item.title, onEdit: { [weak self] in self?.editJogak(jogakID: item.key.jogakID) }, from: self)
    }

    private func editJogak(jogakID: Int) {
        showLoading()
        viewModel.getJogakForEditing(jogakId: jogakID) { [weak self] result in
            guard let self else { return }
            hideLoading()

            switch result {
            case .success(let detail):
                coordinator?.routeToJogakEditing(jogak: detail, from: self)
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }
}

extension MG2ScheduleStartViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarView.snp.updateConstraints {
            $0.height.equalTo(bounds.height)
        }
        view.layoutIfNeeded()
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        headerLabel.text = viewModel.calendarHeader(for: calendar.currentPage)
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        loadJogakOccurrences(date: date)
    }
}

extension MG2ScheduleStartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.state.occurrences.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleJogak(at: indexPath)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MG2JogakOccurrenceCell.reuseIdentifier, for: indexPath) as? MG2JogakOccurrenceCell else { return UITableViewCell() }

        let item = viewModel.state.occurrences[indexPath.row]
        cell.configure(item: item) { [weak self] in self?.showJogakOptions(for: item) }
        return cell
    }
}
