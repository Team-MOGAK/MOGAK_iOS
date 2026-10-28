import SnapKit
import Then
import UIKit

final class MG2ModalartMainViewController: UIViewController {
    weak var coordinator: MG2ModalartCoordinator?

    private let viewModel: MG2ModalartMainViewModel

    private let modalartNameLabel = UILabel().then {
        $0.apply(.title1)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        // 긴 판 이름은 말줄임되고 오른쪽 버튼들을 밀어내지 않는다.
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.isUserInteractionEnabled = true
        $0.accessibilityTraits = .header
    }
    private lazy var showModalartListButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)), for: .normal)
        $0.tintColor = DS.Color.ink
        $0.accessibilityLabel = "모다라트 목록"
        $0.addTarget(self, action: #selector(modalartListButtonTapped), for: .touchUpInside)
    }
    private lazy var modalartMenuButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)), for: .normal)
        $0.tintColor = DS.Color.ink
        $0.backgroundColor = DS.Color.surface
        $0.layer.cornerRadius = DS.Size.touch / 2
        $0.layer.apply(.card)
        $0.accessibilityLabel = "모다라트 메뉴"
        $0.enablePressFeedback()
        $0.addTarget(self, action: #selector(modalartMenuButtonTapped), for: .touchUpInside)
    }
    private lazy var fullBoardButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "square.grid.3x3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)), for: .normal)
        $0.tintColor = DS.Color.ink
        $0.backgroundColor = DS.Color.surface
        $0.layer.cornerRadius = DS.Size.touch / 2
        $0.layer.apply(.card)
        $0.accessibilityLabel = "81칸 전체 보기"
        $0.enablePressFeedback()
        $0.addTarget(self, action: #selector(fullBoardButtonTapped), for: .touchUpInside)
    }
    private let modalartCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.clipsToBounds = false
        $0.isScrollEnabled = false
    }
    private var cellSize = CGSize(width: 100, height: 120)
    private var nameTopConstraint: Constraint?
    /// 다른 판을 불러오는 중. 9칸을 빈 칸으로 그리고 제목 · 9칸을 덩어리로 덮는다.
    private var isLoadingBoard = false

    init(viewModel: MG2ModalartMainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.canvas
        configureCollectionView()
        configureLayout()
        modalartNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(modalartListButtonTapped)))
        loadModalart()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }


    private func configureCollectionView() {
        modalartCollectionView.register(MG2EmptyMogakCell.self, forCellWithReuseIdentifier: MG2EmptyMogakCell.identifier)
        modalartCollectionView.register(MG2MogakCell.self, forCellWithReuseIdentifier: MG2MogakCell.identifier)
        modalartCollectionView.register(MG2ModalartMainCell.self, forCellWithReuseIdentifier: MG2ModalartMainCell.identifier)
        modalartCollectionView.delegate = self
        modalartCollectionView.dataSource = self
    }

    private func configureLayout() {
        view.addSubviews(modalartNameLabel, showModalartListButton, fullBoardButton, modalartMenuButton, modalartCollectionView)
        modalartNameLabel.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(DS.Space.gutter)
            nameTopConstraint = $0.top.equalTo(view.safeAreaLayoutGuide).inset(12).constraint
            $0.trailing.lessThanOrEqualTo(showModalartListButton.snp.leading)
            // 이름이 오기 전에도 한 줄 높이를 지켜 스켈레톤에서 바뀔 때 버튼이 움직이지 않게.
            $0.height.greaterThanOrEqualTo(T.title1.lineHeight)
        }
        showModalartListButton.snp.makeConstraints {
            $0.size.equalTo(DS.Size.touch)
            $0.leading.equalTo(modalartNameLabel.snp.trailing)
            $0.centerY.equalTo(modalartNameLabel)
            $0.trailing.lessThanOrEqualTo(fullBoardButton.snp.leading).offset(-8)
        }
        fullBoardButton.snp.makeConstraints {
            $0.size.equalTo(DS.Size.touch)
            $0.trailing.equalTo(modalartMenuButton.snp.leading).offset(-8)
            $0.centerY.equalTo(modalartNameLabel)
        }
        modalartMenuButton.snp.makeConstraints {
            $0.size.equalTo(DS.Size.touch)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter)
            $0.centerY.equalTo(modalartNameLabel)
        }
        modalartCollectionView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(20).priority(.high)
            $0.top.greaterThanOrEqualTo(modalartNameLabel.snp.bottom).offset(20)
            $0.width.height.equalTo(0)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // iPhone SE(높이 667 이하)는 상단 여백 20.
        nameTopConstraint?.update(inset: view.bounds.height <= 667 ? 20 : 12)
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        let boardWidth = min(safeFrame.width - DS.Space.gutter * 2, MG2MandalaGrid.maxBoardWidth)
        let availableHeight = safeFrame.maxY - modalartNameLabel.frame.maxY - 20
        let size = MG2MandalaGrid.boardCellSize(boardWidth: boardWidth, availableHeight: availableHeight)
        // 처음 불러올 때는 판 크기가 잡힌 뒤에야 칸이 생기니 그때 덮는다.
        if isLoadingBoard { coverBoardCells() }
        guard size != cellSize || modalartCollectionView.bounds.width == 0 else { return }
        cellSize = size
        modalartCollectionView.snp.updateConstraints {
            $0.width.equalTo(size.width * 3 + DS.Space.cellGap * 2)
            $0.height.equalTo(size.height * 3 + DS.Space.cellGap * 2)
        }
        modalartCollectionView.collectionViewLayout.invalidateLayout()
    }

    private func loadModalart() {
        reloadBoard(showsSkeleton: true, viewModel.load)
    }

    private func selectModalart(at index: Int) {
        reloadBoard(showsSkeleton: true) { completion in viewModel.selectModalart(at: index, completion: completion) }
    }

    private func createModalart() {
        reloadBoard(showsSkeleton: true, viewModel.createModalart)
    }

    private func updateModalart(title: String, color: String) {
        reloadBoard(showsSkeleton: false) { completion in viewModel.updateSelectedModalart(title: title, color: color, completion: completion) }
    }

    private func removeSelectedModalart() {
        reloadBoard(showsSkeleton: true, viewModel.deleteSelectedModalart)
    }

    private func reloadSelectedModalart() {
        reloadBoard(showsSkeleton: false, viewModel.reloadSelectedModalart)
    }

    /// 다른 판을 불러올 때(처음 · 목록에서 고르기 · 만들기 · 삭제)는 제목과 9칸을 덩어리로 덮고, 오면 페이드로 바꾼다.
    /// 보이는 판을 다시 부를 때(모각 화면에서 돌아오기 · 제목 수정)는 덮지 않고 조용히 바꾼다. 아이콘 버튼은 늘 그대로.
    private func reloadBoard(showsSkeleton: Bool, _ operation: (@escaping (Result<Void, Error>) -> Void) -> Void) {
        var isFinished = false
        operation { [weak self] result in
            guard let self else { return }
            isFinished = true
            if isLoadingBoard {
                isLoadingBoard = false
                modalartNameLabel.hideSkeletonBlocks()
                modalartCollectionView.hideSkeletonBlocks()
            }
            UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction]) { self.render() }
            if case .failure(let error) = result { coordinator?.presentError(error, from: self) }
        }
        // 둘러보기처럼 바로 끝났으면 덮지 않는다.
        guard showsSkeleton, !isFinished else { return }
        isLoadingBoard = true
        // 제목이 비어 있으면 덩어리 폭이 없으니 자리 글을 넣는다.
        if modalartNameLabel.text?.isEmpty ?? true { modalartNameLabel.text = "모다라트" }
        modalartNameLabel.showSkeletonBlocks()
        modalartCollectionView.reloadData()
        coverBoardCells()
    }

    private func coverBoardCells() {
        modalartCollectionView.layoutIfNeeded()
        modalartCollectionView.showSkeletonBlocks()
    }

    private func render() {
        let state = viewModel.state
        modalartNameLabel.text = state.title
        showModalartListButton.isHidden = viewModel.isGuest
        modalartCollectionView.reloadData()
    }

    /// 그 칸에서 바로 확대해 들어간다. 조각은 모각 화면이 스켈레톤을 띄운 채 불러온다.
    private func openMogakDetail(_ mogak: MG2ModalartMogakItemEntity) {
        // 81칸에서 눌러도 둘러보기면 로그인 안내부터.
        guard !viewModel.isGuest else {
            coordinator?.presentLoginGate(from: self)
            return
        }
        guard let coordinator, let modalartID = viewModel.state.selectedID else { return }
        let sourceCell = viewModel.state.mogaks.firstIndex { $0.mogakId == mogak.mogakId }.flatMap { modalartCollectionView.cellForItem(at: IndexPath(item: MG2MandalaGrid.gridIndex(forContent: $0), section: 0)) }
        coordinator.routeToMogakDetail(mogaks: viewModel.state.mogaks, selectedMogak: mogak, modalartID: modalartID, modalartTitle: viewModel.state.title, sourceView: sourceCell, onExit: { [weak self] in self?.reloadSelectedModalart() }, from: self)
    }

    @objc private func modalartListButtonTapped() {
        guard !viewModel.isGuest else {
            coordinator?.presentLoginGate(from: self)
            return
        }
        coordinator?.presentModalartList(modalarts: viewModel.state.modalarts, onSelection: { [weak self] in self?.selectModalart(at: $0) }, onAdd: { [weak self] in self?.createModalart() }, from: self)
    }

    @objc private func fullBoardButtonTapped() {
        coordinator?.presentFullBoard(modalartTitle: viewModel.state.title, mogaks: viewModel.state.mogaks, isGuest: viewModel.isGuest, onSelectMogak: { [weak self] mogak in self?.openMogakDetail(mogak) }, from: self)
    }

    @objc private func modalartMenuButtonTapped() {
        guard !viewModel.isGuest else {
            coordinator?.presentLoginGate(from: self)
            return
        }
        coordinator?.presentModalartActions(onAdd: { [weak self] in self?.createModalart() }, onDelete: { [weak self] in self?.confirmModalartDeletion() }, from: self)
    }

    private func showMogakSettings(_ mogak: MG2ModalartMogakItemEntity) {
        guard !viewModel.isGuest else {
            coordinator?.presentLoginGate(from: self)
            return
        }
        coordinator?.routeToMogakEditing(mogak: mogak, path: viewModel.mogakPath(for: mogak), from: self) { [weak self] in self?.reloadSelectedModalart() }
    }

    private func confirmModalartDeletion() {
        guard viewModel.state.hasModalart else { return }
        coordinator?.presentDeleteConfirmation(onConfirm: { [weak self] in self?.removeSelectedModalart() }, from: self)
    }
}

extension MG2ModalartMainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        MG2MandalaGrid.itemCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 불러오는 동안은 데이터 없이 빈 칸 9개 (스켈레톤 자리).
        if isLoadingBoard {
            let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2EmptyMogakCell.identifier, for: indexPath)
            (reusableCell as? MG2EmptyMogakCell)?.configure(isSuggested: false)
            return reusableCell
        }
        if indexPath.item == MG2MandalaGrid.centerIndex {
            let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2ModalartMainCell.identifier, for: indexPath)
            guard let cell = reusableCell as? MG2ModalartMainCell else { return reusableCell }
            cell.configure(title: viewModel.state.centerTitle, color: viewModel.state.centerColor, caption: viewModel.state.needsTitle ? nil : "최종 목표")
            return cell
        }

        guard let mogakIndex = MG2MandalaGrid.contentIndex(for: indexPath.item), viewModel.state.mogaks.indices.contains(mogakIndex) else {
            let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2EmptyMogakCell.identifier, for: indexPath)
            // 다음에 채울 칸 하나만 강조.
            (reusableCell as? MG2EmptyMogakCell)?.configure(isSuggested: MG2MandalaGrid.contentIndex(for: indexPath.item) == viewModel.state.mogaks.count && !viewModel.isGuest)
            return reusableCell
        }
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: MG2MogakCell.identifier, for: indexPath)
        guard let cell = reusableCell as? MG2MogakCell else { return reusableCell }
        let mogak = viewModel.state.mogaks[mogakIndex]
        cell.configure(with: mogak) { [weak self] in self?.showMogakSettings(mogak) }
        return cell
    }
}

extension MG2ModalartMainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !viewModel.isGuest else {
            coordinator?.presentLoginGate(from: self)
            return
        }

        if indexPath.item == MG2MandalaGrid.centerIndex {
            coordinator?.presentModalartTitleEditor(title: viewModel.state.needsTitle ? nil : viewModel.state.title, color: viewModel.state.needsTitle ? "" : viewModel.state.color, onSubmit: { [weak self] title, color in self?.updateModalart(title: title, color: color) }, from: self)
            return
        }

        guard let mogakIndex = MG2MandalaGrid.contentIndex(for: indexPath.item) else { return }
        if viewModel.state.mogaks.indices.contains(mogakIndex) {
            openMogakDetail(viewModel.state.mogaks[mogakIndex])
        } else if viewModel.state.needsTitle {
            coordinator?.presentMissingTitleNotice(from: self)
        } else if let modalartID = viewModel.state.selectedID {
            coordinator?.routeToMogakCreation(modalartID: modalartID, path: viewModel.mogakCreationPath, from: self) { [weak self] in self?.reloadSelectedModalart() }
        }
    }
}

extension MG2ModalartMainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        DS.Space.cellGap
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        DS.Space.cellGap
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellSize
    }
}
