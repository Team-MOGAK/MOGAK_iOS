import Combine
import SnapKit
import UIKit

/// 조각시작(홈): 주 · 월 달력 · 진척 카드 · 오늘의 조각 · 조각 더 가져오기 · 목록 끝 네이티브 광고.
final class MG2ScheduleStartViewController: UIViewController {
    weak var coordinator: MG2ScheduleStartCoordinator?

    private let viewModel: MG2ScheduleStartViewModel
    private var cancellables = Set<AnyCancellable>()

    /// 주 · 월 달력. 앱을 열면 오늘을 고른다.
    private lazy var calendarView: MG2PagingCalendarView = {
        let calendarView = MG2PagingCalendarView(calendar: MG2ScheduleStartViewModel.calendar, selectedDate: Date())
        calendarView.onSelectDate = { [weak self] in self?.select($0) }
        calendarView.onVisiblePageChange = { [weak self] _ in self?.updateHeader(animated: true) }
        return calendarView
    }()

    private var selectedDate: Date { calendarView.selectedDate }

    /// 주 · 월 보기 (`Segmented`: 주/월처럼 보기를 바꾸는 세그먼트).
    private lazy var calendarScopeControl: MG2SegmentedControl = {
        let control = MG2SegmentedControl(options: ["주", "월"])
        control.accessibilityLabel = "달력 보기"
        control.addTarget(self, action: #selector(calendarScopeChanged), for: .valueChanged)
        return control
    }()

    private lazy var previousPageButton = makeChevronButton(symbol: "chevron.left", label: "이전 주", action: #selector(previousPageButtonTapped))
    private lazy var nextPageButton = makeChevronButton(symbol: "chevron.right", label: "다음 주", action: #selector(nextPageButtonTapped))

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.apply(.title2)
        label.font = .scaledCapped(UIFont.pretendard(.extraBold, size: 20).withMonospacedDigits(), relativeTo: .title3)
        label.textAlignment = .center
        label.accessibilityTraits = .header
        return label
    }()

    /// 연월 자리는 가장 긴 "0000년 00월" 폭으로 둔다. 9월 ↔ 10월에도 화살표가 움직이지 않는다.
    private lazy var headerSlot: UIView = {
        let probe = UILabel()
        probe.font = headerLabel.font
        probe.adjustsFontForContentSizeCategory = true
        probe.text = "0000년 00월"
        probe.isHidden = true
        let slot = UIView()
        slot.addSubviews(probe, headerLabel)
        probe.snp.makeConstraints { $0.edges.equalToSuperview() }
        headerLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
        return slot
    }()

    private let calendarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = DS.Color.surface
        view.roundCorners(DS.Radius.card)
        view.clipsToBounds = true
        return view
    }()

    /// iPhone SE(높이 667 이하)는 모각이 72.
    private lazy var progressCardView = MG2ProgressCardView(isCompact: view.bounds.height <= 667)

    private lazy var openModalartButton: MG2PrimaryActionButton = {
        let button = MG2PrimaryActionButton(style: .soft)
        button.setTitle("모다라트로 가기", for: .normal)
        button.addTarget(self, action: #selector(createModalartButtonTapped), for: .touchUpInside)
        return button
    }()

    /// 빈 상태는 목록 머리에 넣어 아래 버튼과 겹치지 않게 한다.
    private lazy var emptyView: UIStackView = {
        let mascot = MG2MascotView(size: 88)
        mascot.pose = .wave
        let title = UILabel()
        title.apply(.title2)
        title.text = "오늘의 조각이 없어요"
        title.numberOfLines = 0
        title.textAlignment = .center
        let sub = UILabel()
        sub.apply(.paragraph, color: DS.Color.sub)
        sub.text = "모다라트에서 오늘 할 조각을 가져와 볼까요?"
        sub.numberOfLines = 0
        sub.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [mascot, title, sub, openModalartButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.setCustomSpacing(16, after: sub)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 32, leading: DS.Space.gutter, bottom: 0, trailing: DS.Space.gutter)
        return stack
    }()

    private let scheduleTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = DS.Size.row + 12 + MG2JogakOccurrenceCell.rowSpacing
        return tableView
    }()

    private lazy var addJogakButton: MG2PrimaryActionButton = {
        let button = MG2PrimaryActionButton(style: .dashed)
        button.setTitle("+ 조각 더 가져오기", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
        button.addTarget(self, action: #selector(addJogakButtonTapped), for: .touchUpInside)
        return button
    }()

    private let nativeAdContainer = UIView()
    /// 네이티브 광고 60초 새로 고침. 화면이 보일 때만 돈다.
    private static let nativeAdRefreshInterval: TimeInterval = 60
    private var nativeAdRefreshTimer: Timer?
    private let headerContainer = UIView()
    /// 모각이 말풍선이 카드 위로 20 나온다. 목록은 위에서 자르므로 그만큼 자리를 둔다.
    private static let listTopInset: CGFloat = 12
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
        configureTableView()
        // 첫 응답 전에는 진척 카드 · 빈 상태를 숨긴다.
        progressCardView.isHidden = true
        emptyView.isHidden = true
        updateHeader(animated: false)
        progressCardView.onOpenBoard = { [weak self] in self?.createModalartButtonTapped() }
        viewModel.externalChanges
            .sink { [weak self] in self?.refreshJogakOccurrences() }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
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
        let headerStackView = UIStackView(arrangedSubviews: [previousPageButton, headerSlot, nextPageButton, UIView(), calendarScopeControl])
        headerStackView.alignment = .center
        headerStackView.spacing = 4

        view.addSubviews(headerStackView, calendarContainerView, scheduleTableView)
        calendarContainerView.addSubview(calendarView)

        let headerStack = UIStackView(arrangedSubviews: [progressCardView, emptyView])
        headerStack.axis = .vertical
        headerContainer.addSubview(headerStack)

        // 광고는 ‘+ 조각 더 가져오기’ 아래 24.
        let footerStack = UIStackView(arrangedSubviews: [addJogakButton, nativeAdContainer])
        footerStack.axis = .vertical
        footerStack.spacing = 24
        footerContainer.addSubview(footerStack)

        headerStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter)
            $0.height.greaterThanOrEqualTo(DS.Size.touch)
        }
        [previousPageButton, nextPageButton].forEach { $0.snp.makeConstraints { $0.size.equalTo(DS.Size.touch) } }
        // 옵션마다 좌우 14 + 글자 (`.md-seg button` padding 0 14).
        calendarScopeControl.snp.makeConstraints { $0.width.greaterThanOrEqualTo(88) }
        calendarContainerView.snp.makeConstraints {
            $0.top.equalTo(headerStackView.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter)
        }
        calendarView.snp.makeConstraints { $0.edges.equalToSuperview() }
        scheduleTableView.snp.makeConstraints {
            $0.top.equalTo(calendarContainerView.snp.bottom)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        headerStack.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Self.listTopInset)
            $0.leading.trailing.equalToSuperview()
            // 머리가 비면 위 여백만 남기므로 아래 간격은 양보한다.
            $0.bottom.equalToSuperview().inset(DS.Space.stack).priority(.high)
        }
        footerStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)) }
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
        let isHeaderHidden = accessory === headerContainer && progressCardView.isHidden && emptyView.isHidden
        let height = isHeaderHidden ? Self.listTopInset : accessory.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
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

    // MARK: - 달력

    /// 머리 연월은 보이는 쪽(주간은 고른 날 기준)을 따르고, 바뀔 때만 교차 페이드.
    private func updateHeader(animated: Bool) {
        let text = viewModel.calendarHeader(for: calendarView.titleDate)
        guard headerLabel.text != text else { return }
        guard animated else { return headerLabel.text = text }
        UIView.transition(with: headerLabel, duration: 0.2, options: .transitionCrossDissolve) { self.headerLabel.text = text }
    }

    private func select(_ date: Date) {
        updateHeader(animated: true)
        loadJogakOccurrences(date: date)
    }

    /// 주간 ↔ 월간. 머리 줄은 그대로 두고 달력만 펼치거나 접는다.
    @objc private func calendarScopeChanged() {
        let isMonth = calendarScopeControl.selectedIndex == 1
        calendarView.setScope(isMonth ? .month : .week, animated: true)
        previousPageButton.accessibilityLabel = isMonth ? "이전 달" : "이전 주"
        nextPageButton.accessibilityLabel = isMonth ? "다음 달" : "다음 주"
        updateHeader(animated: true)
        UIAccessibility.post(notification: .layoutChanged, argument: calendarView)
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
        calendarView.scrollToPage(offset: 1, animated: true)
    }

    @objc private func previousPageButtonTapped() {
        calendarView.scrollToPage(offset: -1, animated: true)
    }

    private func refreshJogakOccurrences() {
        loadJogakOccurrences(date: selectedDate)
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
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                progressCardView.mascotView.hop()
                MG2ToastView.show(in: view, title: "‘\(item.title)’ 완료", subtitle: remaining > 0 ? "한 걸음 더 · 남은 \(remaining)개" : nil)
            }
        case .completedAll:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
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
                // 홈에서는 판을 모르니 모각만 보여 준다.
                coordinator?.routeToJogakEditing(jogak: detail, path: [MG2PathItem(label: detail.mogakTitle, colorHex: detail.color)], from: self)
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
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
