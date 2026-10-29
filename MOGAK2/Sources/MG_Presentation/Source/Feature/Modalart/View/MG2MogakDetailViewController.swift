import SnapKit
import Then
import UIKit

final class MG2MogakDetailViewController: UIViewController {
    weak var coordinator: MG2ModalartCoordinator?
    var onExit: (() -> Void)?

    private let viewModel: MG2MogakDetailViewModel

    private lazy var deleteButton = UIBarButtonItem(title: "모각 삭제", style: .plain, target: self, action: #selector(deleteButtonTapped)).then {
        $0.tintColor = DS.Color.danger
        // `.md-btn-danger` 15/700
        $0.setTitleTextAttributes([.font: T.subhead.font], for: .normal)
    }
    private let mogakListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.scrollDirection = .horizontal
        layout?.minimumLineSpacing = 8
        layout?.sectionInset = UIEdgeInsets(top: 0, left: DS.Space.gutter, bottom: 0, right: DS.Space.gutter)
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
    }
    private let jogakCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.clipsToBounds = false
        $0.isScrollEnabled = false
    }
    private var cellSize = CGSize(width: 100, height: 120)
    /// 다른 모각의 조각을 불러오는 중. 조각 8칸을 빈 칸으로 그리고 덩어리로 덮는다 (모각 칩 · 가운데 모각 칸은 이미 안다).
    private var isLoadingJogaks = false
    /// 마지막으로 시작한 불러오기. 칩을 빨리 바꾸면 앞서 시작한 것이 늦게 와도 그리지 않는다.
    private var latestLoadID = 0

    init(viewModel: MG2MogakDetailViewModel) {
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
        configureCollectionViews()
        render()
        reload(showsSkeleton: true, viewModel.reloadOccurrences)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyStepNavigationBar()
        navigationItem.title = "모각"
        updateDeleteButton()
    }

    /// 판 칸으로 돌아가는 확대 전환이 끝난 뒤에 판을 다시 불러온다 (밀어서 닫다 취소하면 부르지 않는다).
    /// 위에 폼이 떠 있는 채 탭을 눌러 한 번에 빠져도 불리도록 화면에서 빠질 때를 본다.
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            onExit?()
        }
    }

    private func configureLayout() {
        view.addSubviews(mogakListCollectionView, jogakCollectionView)
        mogakListCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(DS.Size.touch)
        }
        jogakCollectionView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(20).priority(.high)
            $0.top.greaterThanOrEqualTo(mogakListCollectionView.snp.bottom).offset(16)
            $0.width.height.equalTo(0)
        }
    }

    /// 판 화면과 같은 칸 크기 공식 · 560pt 가운데 열.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        let boardWidth = min(safeFrame.width - DS.Space.gutter * 2, MG2MandalaGrid.maxBoardWidth)
        let size = MG2MandalaGrid.boardCellSize(boardWidth: boardWidth, availableHeight: safeFrame.maxY - mogakListCollectionView.frame.maxY - 16)
        // 처음 열 때는 판 크기가 잡힌 뒤에야 칸이 생기니 그때 덮는다.
        if isLoadingJogaks { coverJogakCells() }
        guard size != cellSize || jogakCollectionView.bounds.width == 0 else { return }
        cellSize = size
        jogakCollectionView.snp.updateConstraints {
            $0.width.equalTo(size.width * 3 + DS.Space.cellGap * 2)
            $0.height.equalTo(size.height * 3 + DS.Space.cellGap * 2)
        }
        jogakCollectionView.collectionViewLayout.invalidateLayout()
    }

    private func configureCollectionViews() {
        mogakListCollectionView.register(MG2MogakListCell.self, forCellWithReuseIdentifier: MG2MogakListCell.identifier)
        mogakListCollectionView.dataSource = self
        mogakListCollectionView.delegate = self

        jogakCollectionView.register(MG2EmptyMogakCell.self, forCellWithReuseIdentifier: MG2EmptyMogakCell.identifier)
        jogakCollectionView.register(MG2ModalartMainCell.self, forCellWithReuseIdentifier: MG2ModalartMainCell.identifier)
        jogakCollectionView.register(MG2JogakCell.self, forCellWithReuseIdentifier: MG2JogakCell.identifier)
        jogakCollectionView.register(MG2RoutineJogakCell.self, forCellWithReuseIdentifier: MG2RoutineJogakCell.routineIdentifier)
        jogakCollectionView.dataSource = self
        jogakCollectionView.delegate = self
    }

    private func render() {
        mogakListCollectionView.reloadData()
        jogakCollectionView.reloadData()
        updateDeleteButton()

        guard let index = viewModel.state.mogaks.firstIndex(where: { $0.mogakId == viewModel.state.selectedMogakID }) else { return }
        mogakListCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
    }

    private func updateDeleteButton() {
        navigationItem.rightBarButtonItem = viewModel.state.selectedMogak == nil ? nil : deleteButton
    }

    /// 다른 모각으로 바뀌니 조각 칸을 덮는다.
    private func removeSelectedMogak() {
        reload(showsSkeleton: true) { [viewModel] completion in
            viewModel.deleteSelectedMogak { [weak self] result in
                completion(result.map { _ in })
                if case .success(.noMogaksRemaining) = result, let self { self.coordinator?.presentNoMogaksRemaining(from: self) }
            }
        }
    }

    private func editJogak(_ jogak: MG2JogakDetailEntity) {
        coordinator?.routeToJogakEditing(jogak: jogak, path: viewModel.mogakPath, from: self) { [weak self] in self?.reloadOccurrences() }
    }

    private func confirmJogakDeletion(_ jogak: MG2JogakDetailEntity) {
        coordinator?.presentDeleteConfirmation(onConfirm: { [weak self] in self?.removeJogak(id: jogak.jogakID) }, from: self)
    }

    private func editMogak(_ mogak: MG2ModalartMogakItemEntity) {
        coordinator?.routeToMogakEditing(mogak: mogak, path: viewModel.mogakPath, from: self) { [weak self] in self?.reloadMogaks() }
    }

    private func confirmMogakDeletion() {
        coordinator?.presentDeleteConfirmation(onConfirm: { [weak self] in self?.removeSelectedMogak() }, from: self)
    }

    /// 조각 만들기 · 수정 뒤.
    private func reloadOccurrences() {
        reload(showsSkeleton: false, viewModel.reloadOccurrences)
    }

    /// 모각 수정 뒤.
    private func reloadMogaks() {
        reload(showsSkeleton: false, viewModel.reloadMogaks)
    }

    private func removeJogak(id: Int) {
        reload(showsSkeleton: false) { completion in viewModel.deleteJogak(id: id, completion: completion) }
    }

    /// 다른 모각의 조각을 불러올 때(처음 · 칩 바꾸기 · 모각 삭제)는 조각 8칸만 덮고, 오면 페이드로 바꾼다.
    /// 보이는 조각을 다시 부를 때(수정 · 조각 삭제 뒤)는 덮지 않고 조용히 바꾼다.
    private func reload(showsSkeleton: Bool, _ operation: (@escaping (Result<Void, Error>) -> Void) -> Void) {
        latestLoadID += 1
        let loadID = latestLoadID
        var isFinished = false
        operation { [weak self] result in
            guard let self else { return }
            isFinished = true
            // 화면 전환 중이면 끝난 뒤에 바꾼다 (전환과 겹쳐 움직이지 않게).
            afterTransition { [weak self] in
                guard let self else { return }
                if loadID == latestLoadID {
                    if isLoadingJogaks {
                        isLoadingJogaks = false
                        jogakCollectionView.hideSkeletonBlocks()
                    }
                    UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction]) { self.render() }
                }
                if case .failure(let error) = result { coordinator?.presentError(error, from: self) }
            }
        }
        guard showsSkeleton, !isFinished else { return }
        isLoadingJogaks = true
        jogakCollectionView.reloadData()
        coverJogakCells()
    }

    private func coverJogakCells() {
        jogakCollectionView.layoutIfNeeded()
        jogakCollectionView.showSkeletonBlocks(where: { $0.item != MG2MandalaGrid.centerIndex })
    }

    private func showJogakActions(for occurrence: MG2JogakOccurrenceEntity) {
        let finish = beginPendingTransition()
        viewModel.loadJogakActionContext(for: occurrence) { [weak self] result in
            finish()
            guard let self else { return }
            switch result {
            case .success(let context):
                coordinator?.presentJogakActions(viewData: context.summary, onEdit: { [weak self] in self?.editJogak(context.detail) }, onDelete: { [weak self] in self?.confirmJogakDeletion(context.detail) }, from: self)
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    @objc private func deleteButtonTapped() {
        guard let selectedMogak = viewModel.state.selectedMogak else { return }
        coordinator?.presentDeleteAction(title: selectedMogak.title, message: "이 모각과 안의 조각을 삭제할까요?", onConfirm: { [weak self] in self?.removeSelectedMogak() }, from: self)
    }
}

extension MG2MogakDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mogakListCollectionView {
            return viewModel.state.mogaks.count
        }
        return viewModel.state.selectedMogak == nil ? 0 : MG2MandalaGrid.itemCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mogakListCollectionView {
            let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2MogakListCell.identifier, for: indexPath)
            guard let cell = reusableCell as? MG2MogakListCell, viewModel.state.mogaks.indices.contains(indexPath.item) else { return reusableCell }
            let mogak = viewModel.state.mogaks[indexPath.item]
            cell.configure(title: mogak.title, color: mogak.color)
            return cell
        }

        guard let selectedMogak = viewModel.state.selectedMogak else { return emptyCell(collectionView, at: indexPath) }
        if indexPath.item == MG2MandalaGrid.centerIndex {
            let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2ModalartMainCell.identifier, for: indexPath)
            guard let cell = reusableCell as? MG2ModalartMainCell else { return reusableCell }
            cell.configure(title: selectedMogak.title, color: selectedMogak.color ?? DesignSystemPalette.signatureHex, caption: selectedMogak.category.name)
            return cell
        }

        // 불러오는 동안 조각 자리는 빈 칸 (스켈레톤 자리).
        guard !isLoadingJogaks, let jogakIndex = MG2MandalaGrid.contentIndex(for: indexPath.item), viewModel.state.occurrences.indices.contains(jogakIndex) else { return emptyCell(collectionView, at: indexPath) }
        let occurrence = viewModel.state.occurrences[jogakIndex]
        if occurrence.isRoutine {
            let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2RoutineJogakCell.routineIdentifier, for: indexPath)
            guard let cell = reusableCell as? MG2RoutineJogakCell else { return reusableCell }
            cell.configure(badgeText: viewModel.routineDaysText(for: occurrence), title: occurrence.title, color: selectedMogak.color ?? DesignSystemPalette.signatureHex)
            return cell
        }

        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2JogakCell.identifier, for: indexPath)
        guard let cell = reusableCell as? MG2JogakCell else { return reusableCell }
        cell.configure(title: occurrence.title)
        return cell
    }

    /// 빈 칸: 다음에 채울 칸 하나만 "조각 추가"로 강조.
    private func emptyCell(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2EmptyMogakCell.identifier, for: indexPath)
        let isNext = !isLoadingJogaks && MG2MandalaGrid.contentIndex(for: indexPath.item) == viewModel.state.occurrences.count && viewModel.state.selectedMogak != nil
        (reusableCell as? MG2EmptyMogakCell)?.configure(isSuggested: isNext, label: "조각 추가")
        return reusableCell
    }
}

extension MG2MogakDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mogakListCollectionView {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            reload(showsSkeleton: true) { completion in viewModel.selectMogak(at: indexPath.item, completion: completion) }
            return
        }

        guard let selectedMogak = viewModel.state.selectedMogak else { return }
        if indexPath.item == MG2MandalaGrid.centerIndex {
            coordinator?.presentMogakActions(mogak: selectedMogak, onEdit: { [weak self] in self?.editMogak(selectedMogak) }, onDelete: { [weak self] in self?.confirmMogakDeletion() }, from: self)
            return
        }

        guard let jogakIndex = MG2MandalaGrid.contentIndex(for: indexPath.item) else { return }
        guard viewModel.state.occurrences.indices.contains(jogakIndex) else {
            coordinator?.routeToJogakCreation(mogak: selectedMogak, path: viewModel.jogakCreationPath, from: self) { [weak self] in self?.reloadOccurrences() }
            return
        }

        showJogakActions(for: viewModel.state.occurrences[jogakIndex])
    }
}

extension MG2MogakDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == mogakListCollectionView {
            // 모각 목록은 조각보다 먼저 바뀐다. 예전 칸 수로 물어도 터지지 않게 칸 그리기와 같이 막는다.
            guard viewModel.state.mogaks.indices.contains(indexPath.item) else { return .zero }
            return MG2MogakListCell.size(for: viewModel.state.mogaks[indexPath.item].title)
        }
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        collectionView == mogakListCollectionView ? UIEdgeInsets(top: 0, left: DS.Space.gutter, bottom: 0, right: DS.Space.gutter) : .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        collectionView == mogakListCollectionView ? 8 : DS.Space.cellGap
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        collectionView == mogakListCollectionView ? 8 : DS.Space.cellGap
    }
}
