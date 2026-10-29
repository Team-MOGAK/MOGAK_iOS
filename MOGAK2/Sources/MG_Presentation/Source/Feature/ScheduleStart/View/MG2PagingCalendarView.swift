import SnapKit
import UIKit

/// iOS 캘린더 같은 주 · 월 달력. 고정된 요일 줄 아래 가로 페이지 한 쪽이 한 주(주간) · 한 달(월간)이다.
/// 손가락을 따라 넘어가고 쪽 단위로 멈춘다. 월간은 그 달 줄 수(4~6)에 맞춰 높이가 스프링으로 바뀐다.
final class MG2PagingCalendarView: UIView {
    enum Scope {
        case week, month
    }

    var onSelectDate: ((Date) -> Void)?
    /// 쪽이 멈추면 `titleDate`를 넘긴다.
    var onVisiblePageChange: ((Date) -> Void)?

    private(set) var scope = Scope.week
    private(set) var selectedDate: Date

    /// 머리 연월에 쓸 날: 월간은 그 달 1일, 주간은 고른 날이 그 주에 있으면 그 날, 아니면 주 첫날.
    var titleDate: Date {
        let start = pageStart(at: pageIndex)
        guard scope == .week, (0..<7).contains(dayOffset(from: start, to: selectedDate)) else { return start }
        return selectedDate
    }

    /// 오늘이 든 주 · 달을 가운데에 두고 앞뒤 10년. 쪽 날짜는 번호로 그때그때 계산한다.
    private static let weekSpan = 520
    private static let monthSpan = 120

    private let calendar: Calendar
    private let dayFormatter = DateFormatter()
    private lazy var anchorWeek = weekStart(of: Date())
    private lazy var anchorMonth = monthStart(of: Date())
    private lazy var pageIndex = index(of: selectedDate)
    /// 손을 뗐거나 화살표로 가고 있는 쪽. 높이는 여기에 맞춘다.
    private lazy var targetIndex = pageIndex
    private var visibleRows = 1
    private var lastWidth: CGFloat = 0
    private var clipHeight: Constraint?
    private weak var transitionPage: MG2CalendarPageView?

    private lazy var weekdayRow: UIStackView = {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let labels = (0..<7).map { offset in
            let label = UILabel()
            label.apply(.caption1, color: DS.Color.muted)
            label.textAlignment = .center
            label.text = symbols[(calendar.firstWeekday - 1 + offset) % 7]
            return label
        }
        let stack = UIStackView(arrangedSubviews: labels)
        stack.distribution = .fillEqually
        // 요일은 날마다 VoiceOver 이름에 들어 있다.
        stack.accessibilityElementsHidden = true
        return stack
    }()

    /// 보이는 줄 수만큼만 보여 준다. 컬렉션은 늘 6줄 높이라 높이가 바뀌어도 쪽 배치가 그대로다.
    private let clipView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [NSCollectionLayoutItem(layoutSize: size)])
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        let layout = UICollectionViewCompositionalLayout(section: NSCollectionLayoutSection(group: group), configuration: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        // 상태 막대 탭은 아래 목록이 받는다.
        collectionView.scrollsToTop = false
        // 고른 날이 바뀌면 보이는 쪽만 다시 칠하므로 미리 만든 쪽을 두지 않는다.
        collectionView.isPrefetchingEnabled = false
        collectionView.register(MG2CalendarPageCell.self, forCellWithReuseIdentifier: MG2CalendarPageCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private var pageCount: Int { (scope == .week ? Self.weekSpan : Self.monthSpan) * 2 + 1 }
    /// 카드 아래 목록까지 같은 스프링으로 움직이도록 창 전체를 다시 배치한다.
    private var layoutRoot: UIView { window ?? self }

    init(calendar: Calendar, selectedDate: Date) {
        self.calendar = calendar
        self.selectedDate = calendar.startOfDay(for: selectedDate)
        super.init(frame: .zero)
        dayFormatter.calendar = calendar
        dayFormatter.locale = calendar.locale
        dayFormatter.dateFormat = "M월 d일 EEEE"

        addSubviews(weekdayRow, clipView)
        clipView.addSubview(collectionView)
        weekdayRow.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(MG2CalendarPageView.inset)
        }
        clipView.snp.makeConstraints {
            $0.top.equalTo(weekdayRow.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(4)
            clipHeight = $0.height.equalTo(MG2CalendarPageView.rowHeight).constraint
        }
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(MG2CalendarPageView.rowHeight * CGFloat(MG2CalendarPageView.maxRows))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 폭이 정해지거나 바뀌면 지금 쪽에 맞춘다. 내용 크기가 잡힌 뒤에 옮겨야 0으로 당겨지지 않는다.
        guard bounds.width > 0, bounds.width != lastWidth else { return }
        lastWidth = bounds.width
        clipView.layoutIfNeeded()
        collectionView.contentOffset = CGPoint(x: CGFloat(pageIndex) * bounds.width, y: 0)
    }

    /// 자정이 지나면 부른다. 오늘 표시를 새로 그리고 `date`를 골라 그 쪽을 보여 준다.
    func reset(selecting date: Date) {
        selectedDate = calendar.startOfDay(for: date)
        collectionView.reloadData()
        scroll(to: index(of: selectedDate), animated: false)
    }

    /// 화살표: 옆 쪽으로 미끄러져 넘어간다.
    func scrollToPage(offset: Int, animated: Bool) {
        scroll(to: targetIndex + offset, animated: animated)
    }

    /// 주간 ↔ 월간. iOS 캘린더처럼 남는 주를 두고 나머지 줄이 거기서 펼쳐지거나 거기로 접히며, 높이도 같은 스프링으로 바뀐다.
    func setScope(_ newScope: Scope, animated: Bool) {
        guard newScope != scope else { return }
        let expands = newScope == .month
        // 펼치거나 접을 달과 그 달에서 남는 주.
        let month = expands ? monthStart(of: titleDate) : pageStart(at: pageIndex)
        let fullMonth = monthPage(month)
        let keptWeek: Date
        if expands {
            keptWeek = pageStart(at: pageIndex)
        } else if (0..<fullMonth.rowCount * 7).contains(dayOffset(from: fullMonth.gridStart, to: selectedDate)) {
            keptWeek = weekStart(of: selectedDate)
        } else {
            // 고른 날이 이 달에 없으면 이 달에서 시작하는 첫 주 (머리 연월이 그대로다).
            keptWeek = weekStart(of: calendar.date(byAdding: .day, value: 6, to: month) ?? month)
        }
        let anchorRow = min(max(dayOffset(from: fullMonth.gridStart, to: keptWeek) / 7, 0), fullMonth.rowCount - 1)

        let switchPages = { [self] in
            scope = newScope
            pageIndex = index(of: expands ? month : keptWeek)
            targetIndex = pageIndex
            collectionView.reloadData()
            collectionView.contentOffset = CGPoint(x: CGFloat(pageIndex) * collectionView.bounds.width, y: 0)
            UIView.performWithoutAnimation { collectionView.layoutIfNeeded() }
            updateHeight(animated: false)
        }
        guard animated, window != nil else { return switchPages() }
        guard !UIAccessibility.isReduceMotionEnabled else {
            UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction]) {
                switchPages()
                self.layoutRoot.layoutIfNeeded()
            }
            return
        }

        // 지금 보이는 모습과 똑같은 한 장을 덮고, 그 아래에서 컬렉션을 새 보기로 바꿔 둔다.
        transitionPage?.removeFromSuperview()
        let transition = MG2CalendarPageView()
        transition.isUserInteractionEnabled = false
        transition.frame = collectionView.frame
        var shown = fullMonth
        shown.month = expands ? nil : month
        transition.configure(shown, selectedDate: selectedDate)
        transition.fold(toRow: anchorRow, folded: expands)
        clipView.addSubview(transition)
        transition.layoutIfNeeded()
        transitionPage = transition
        collectionView.isHidden = true
        switchPages()

        UIView.animate(springDuration: 0.45, bounce: 0) {
            transition.fold(toRow: anchorRow, folded: !expands)
            self.layoutRoot.layoutIfNeeded()
        } completion: { _ in
            if self.transitionPage === transition { self.collectionView.isHidden = false }
            transition.removeFromSuperview()
        }
        // 달 밖 날짜 색은 같은 때 교차 페이드.
        transition.month = expands ? month : nil
        transition.render(selectedDate: selectedDate, animated: true)
    }

    // MARK: - 쪽

    private func pageStart(at index: Int) -> Date {
        switch scope {
        case .week: return calendar.date(byAdding: .day, value: 7 * (index - Self.weekSpan), to: anchorWeek) ?? anchorWeek
        case .month: return calendar.date(byAdding: .month, value: index - Self.monthSpan, to: anchorMonth) ?? anchorMonth
        }
    }

    private func index(of date: Date) -> Int {
        switch scope {
        case .week: return clamped(Self.weekSpan + dayOffset(from: anchorWeek, to: weekStart(of: date)) / 7)
        case .month: return clamped(Self.monthSpan + (calendar.dateComponents([.month], from: anchorMonth, to: monthStart(of: date)).month ?? 0))
        }
    }

    private func page(at index: Int) -> MG2CalendarPage {
        let start = pageStart(at: index)
        return scope == .week ? MG2CalendarPage(gridStart: start, rowCount: 1, month: nil, calendar: calendar, formatter: dayFormatter) : monthPage(start)
    }

    private func monthPage(_ month: Date) -> MG2CalendarPage {
        let gridStart = weekStart(of: month)
        let days = calendar.range(of: .day, in: .month, for: month)?.count ?? 31
        return MG2CalendarPage(gridStart: gridStart, rowCount: (dayOffset(from: gridStart, to: month) + days + 6) / 7, month: month, calendar: calendar, formatter: dayFormatter)
    }

    private func weekStart(of date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
    }

    private func monthStart(of date: Date) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? calendar.startOfDay(for: date)
    }

    private func dayOffset(from start: Date, to end: Date) -> Int {
        calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    private func clamped(_ index: Int) -> Int {
        min(max(index, 0), pageCount - 1)
    }

    private func index(atOffset x: CGFloat) -> Int? {
        let width = collectionView.bounds.width
        return width > 0 ? clamped(Int((x / width).rounded())) : nil
    }

    private func scroll(to page: Int, animated: Bool) {
        let target = clamped(page)
        retarget(target)
        collectionView.setContentOffset(CGPoint(x: CGFloat(target) * collectionView.bounds.width, y: 0), animated: animated)
        if !animated { pageDidSettle() }
    }

    private func retarget(_ index: Int) {
        guard index != targetIndex else { return }
        targetIndex = index
        updateHeight(animated: true)
    }

    private func pageDidSettle() {
        guard let settled = index(atOffset: collectionView.contentOffset.x) else { return }
        retarget(settled)
        guard settled != pageIndex else { return }
        pageIndex = settled
        onVisiblePageChange?(titleDate)
    }

    private func updateHeight(animated: Bool) {
        let rows = page(at: targetIndex).rowCount
        guard rows != visibleRows else { return }
        visibleRows = rows
        clipHeight?.update(offset: MG2CalendarPageView.rowHeight * CGFloat(rows))
        guard animated, window != nil else { return }
        UIView.animate(springDuration: 0.45, bounce: 0, initialSpringVelocity: 0, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.layoutRoot.layoutIfNeeded()
        }
    }

    private func didTap(_ date: Date) {
        selectedDate = date
        for case let cell as MG2CalendarPageCell in collectionView.visibleCells {
            cell.pageView.render(selectedDate: date, animated: true)
        }
        // 월간에서 달 밖의 날을 고르면 그 달로 넘긴다.
        let datePage = index(of: date)
        if scope == .month, datePage != pageIndex { scroll(to: datePage, animated: true) }
        onSelectDate?(date)
    }
}

extension MG2PagingCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2CalendarPageCell.reuseIdentifier, for: indexPath) as? MG2CalendarPageCell else { return UICollectionViewCell() }
        cell.pageView.configure(page(at: indexPath.item), selectedDate: selectedDate)
        cell.pageView.onSelect = { [weak self] in self?.didTap($0) }
        return cell
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // 손을 떼는 순간 갈 쪽이 정해지므로 높이는 미끄러지는 동안 함께 바뀐다.
        if let target = index(atOffset: targetContentOffset.pointee.x) { retarget(target) }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { pageDidSettle() }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageDidSettle()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageDidSettle()
    }
}

/// 한 쪽: 첫 칸 날짜부터 7일씩 `rowCount`줄. `month`가 있으면 그 달 밖의 날은 흐리게.
private struct MG2CalendarPage {
    let gridStart: Date
    let rowCount: Int
    var month: Date?
    let calendar: Calendar
    let formatter: DateFormatter
}

private final class MG2CalendarPageCell: UICollectionViewCell {
    static let reuseIdentifier = "MG2CalendarPageCell"
    let pageView = MG2CalendarPageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(pageView)
        pageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 날짜 칸 7열 × 줄. 줄마다 따로 움직일 수 있어 주 ↔ 월 전환에도 쓴다.
private final class MG2CalendarPageView: UIView {
    static let rowHeight = DS.Size.touch
    static let maxRows = 6
    static let inset: CGFloat = 4

    var onSelect: ((Date) -> Void)?
    var month: Date?

    private let rows = (0..<MG2CalendarPageView.maxRows).map { _ in UIView() }
    private var controls = [[MG2CalendarDayControl]]()
    private var calendar = Calendar.current

    override init(frame: CGRect) {
        super.init(frame: frame)
        controls = rows.map { row in
            addSubview(row)
            return (0..<7).map { _ in
                let control = MG2CalendarDayControl()
                control.addTarget(self, action: #selector(controlTapped(_:)), for: .touchUpInside)
                row.addSubview(control)
                return control
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 줄은 전환 중 transform이 걸리므로 bounds · center로 놓는다. 칸은 포인트 단위로 맞춘다.
        let columnWidth = (bounds.width - Self.inset * 2) / 7
        for (rowIndex, row) in rows.enumerated() {
            row.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: Self.rowHeight)
            row.center = CGPoint(x: bounds.midX, y: Self.rowHeight * (CGFloat(rowIndex) + 0.5))
            for (column, control) in controls[rowIndex].enumerated() {
                let minX = (Self.inset + columnWidth * CGFloat(column)).rounded()
                let maxX = (Self.inset + columnWidth * CGFloat(column + 1)).rounded()
                control.frame = CGRect(x: minX, y: 0, width: maxX - minX, height: Self.rowHeight)
            }
        }
    }

    func configure(_ page: MG2CalendarPage, selectedDate: Date) {
        calendar = page.calendar
        month = page.month
        for (rowIndex, row) in rows.enumerated() {
            row.isHidden = rowIndex >= page.rowCount
            guard !row.isHidden else { continue }
            for (column, control) in controls[rowIndex].enumerated() {
                let date = calendar.date(byAdding: .day, value: rowIndex * 7 + column, to: page.gridStart) ?? page.gridStart
                control.configure(date: date, number: String(calendar.component(.day, from: date)), label: page.formatter.string(from: date), isToday: calendar.isDateInToday(date))
            }
        }
        render(selectedDate: selectedDate, animated: false)
    }

    func render(selectedDate: Date, animated: Bool) {
        for (rowIndex, row) in rows.enumerated() where !row.isHidden {
            for control in controls[rowIndex] {
                let isOutside = month.map { !calendar.isDate(control.date, equalTo: $0, toGranularity: .month) } ?? false
                control.render(isSelected: calendar.isDate(control.date, inSameDayAs: selectedDate), isOutside: isOutside, animated: animated)
            }
        }
    }

    /// 접힌 모양(주간): 모든 줄이 맨 위 한 줄 자리에 모이고 남는 줄만 보인다.
    func fold(toRow anchorRow: Int, folded: Bool) {
        bringSubviewToFront(rows[anchorRow])
        for (rowIndex, row) in rows.enumerated() {
            row.transform = folded ? CGAffineTransform(translationX: 0, y: -Self.rowHeight * CGFloat(rowIndex)) : .identity
            row.alpha = folded && rowIndex != anchorRow ? 0 : 1
        }
    }

    @objc private func controlTapped(_ sender: MG2CalendarDayControl) {
        onSelect?(sender.date)
    }
}

/// 하루 칸 (44pt 이상): 날짜는 36pt 원 가운데(15/700 · 고정폭 숫자), 큰 글자에서는 원이 커지되 칸 폭을 넘지 않는다.
/// 고른 날 accent 원 · 흰 글자, 오늘 accentSoft 원 · accentDeep 글자, 달 밖 placeholder, 나머지 ink.
private final class MG2CalendarDayControl: UIControl {
    private(set) var date = Date()
    private var isToday = false
    private let circleView = UIView()
    private let numberLabel = UILabel()

    override var isHighlighted: Bool {
        didSet { circleView.alpha = isHighlighted ? 0.6 : 1 }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        numberLabel.font = .scaledCapped(UIFont.pretendard(.bold, size: 15).withMonospacedDigits(), relativeTo: .subheadline)
        numberLabel.adjustsFontForContentSizeCategory = true
        numberLabel.adjustsFontSizeToFitWidth = true
        numberLabel.minimumScaleFactor = 0.8
        numberLabel.textAlignment = .center
        circleView.isUserInteractionEnabled = false
        addSubview(circleView)
        circleView.addSubview(numberLabel)
        isAccessibilityElement = true
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _: UITraitCollection) in
            self.setNeedsLayout()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 원은 선택 때 transform이 걸리므로 bounds · center로 놓는다.
        let text = numberLabel.intrinsicContentSize
        let diameter = min(bounds.width, bounds.height, max(36, text.width.rounded(.up) + 8, text.height.rounded(.up) + 4))
        let origin = CGPoint(x: ((bounds.width - diameter) / 2).rounded(), y: ((bounds.height - diameter) / 2).rounded())
        circleView.bounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        circleView.center = CGPoint(x: origin.x + diameter / 2, y: origin.y + diameter / 2)
        circleView.layer.cornerRadius = diameter / 2
        numberLabel.frame = circleView.bounds
    }

    func configure(date: Date, number: String, label: String, isToday: Bool) {
        self.date = date
        self.isToday = isToday
        numberLabel.text = number
        accessibilityLabel = label
        accessibilityValue = isToday ? "오늘" : nil
    }

    func render(isSelected: Bool, isOutside: Bool, animated: Bool) {
        let popsIn = animated && isSelected && !self.isSelected && !UIAccessibility.isReduceMotionEnabled
        self.isSelected = isSelected
        accessibilityTraits = isSelected ? [.button, .selected] : .button
        let fill = isSelected ? DS.Color.accent : (isToday ? DS.Color.accentSoft : .clear)
        let textColor = isSelected ? DS.Color.surface : (isToday ? DS.Color.accentDeep : (isOutside ? DS.Color.placeholder : DS.Color.ink))
        guard animated else {
            circleView.transform = .identity
            circleView.backgroundColor = fill
            numberLabel.textColor = textColor
            return
        }
        if numberLabel.textColor != textColor {
            UIView.transition(with: numberLabel, duration: 0.2, options: [.transitionCrossDissolve, .allowUserInteraction]) { self.numberLabel.textColor = textColor }
        }
        if popsIn {
            // 새로 고른 날 원은 작게 시작해 살짝 튕기며 자리 잡는다.
            circleView.backgroundColor = fill
            circleView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(springDuration: 0.3, bounce: 0.3, initialSpringVelocity: 0, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.circleView.transform = .identity
            }
        } else if circleView.backgroundColor != fill {
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction) { self.circleView.backgroundColor = fill }
        }
    }
}
