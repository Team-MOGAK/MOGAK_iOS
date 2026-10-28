import SnapKit
import Then
import UIKit

final class MG2ModalartMainViewController: UIViewController {
    weak var coordinator: MG2ModalartCoordinator?

    private let viewModel: MG2ModalartMainViewModel

    private let modalartNameLabel = UILabel().then {
        $0.apply(.title1)
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
        $0.addTarget(self, action: #selector(modalartMenuButtonTapped), for: .touchUpInside)
    }
    private let modalartCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.clipsToBounds = false
        $0.isScrollEnabled = false
    }
    private var cellSize = CGSize(width: 100, height: 120)
    private var nameTopConstraint: Constraint?

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
        view.addSubviews(modalartNameLabel, showModalartListButton, modalartMenuButton, modalartCollectionView)
        modalartNameLabel.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(DS.Space.gutter)
            nameTopConstraint = $0.top.equalTo(view.safeAreaLayoutGuide).inset(12).constraint
            $0.trailing.lessThanOrEqualTo(showModalartListButton.snp.leading)
        }
        showModalartListButton.snp.makeConstraints {
            $0.size.equalTo(DS.Size.touch)
            $0.leading.equalTo(modalartNameLabel.snp.trailing)
            $0.centerY.equalTo(modalartNameLabel)
            $0.trailing.lessThanOrEqualTo(modalartMenuButton.snp.leading).offset(-8)
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
        guard size != cellSize || modalartCollectionView.bounds.width == 0 else { return }
        cellSize = size
        modalartCollectionView.snp.updateConstraints {
            $0.width.equalTo(size.width * 3 + DS.Space.cellGap * 2)
            $0.height.equalTo(size.height * 3 + DS.Space.cellGap * 2)
        }
        modalartCollectionView.collectionViewLayout.invalidateLayout()
    }

    private func loadModalart() {
        performLoading(viewModel.load)
    }

    private func selectModalart(at index: Int) {
        performLoading { completion in viewModel.selectModalart(at: index, completion: completion) }
    }

    private func createModalart() {
        performLoading(viewModel.createModalart)
    }

    private func updateModalart(title: String, color: String) {
        performLoading { completion in viewModel.updateSelectedModalart(title: title, color: color, completion: completion) }
    }

    private func removeSelectedModalart() {
        performLoading(viewModel.deleteSelectedModalart)
    }

    private func reloadSelectedModalart() {
        performLoading(viewModel.reloadSelectedModalart)
    }

    private func performLoading(_ operation: (@escaping (Result<Void, Error>) -> Void) -> Void) {
        showLoading()
        view.isUserInteractionEnabled = false
        operation { [weak self] result in
            guard let self else { return }
            hideLoading()
            view.isUserInteractionEnabled = true
            switch result {
            case .success:
                render()
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    private func render() {
        let state = viewModel.state
        modalartNameLabel.text = state.title
        showModalartListButton.isHidden = viewModel.isGuest
        modalartCollectionView.reloadData()
    }

    private func openMogakDetail(_ mogak: MG2ModalartMogakItemEntity, from indexPath: IndexPath) {
        let originFrame = modalartCollectionView.cellForItem(at: indexPath).map { $0.convert($0.bounds, to: nil) }
        showLoading()
        view.isUserInteractionEnabled = false
        viewModel.loadOccurrences(for: mogak) { [weak self] result in
            guard let self else { return }
            hideLoading()
            view.isUserInteractionEnabled = true
            switch result {
            case .success(let occurrences):
                guard let modalartID = viewModel.state.selectedID else { return }
                coordinator?.routeToMogakDetail(mogaks: viewModel.state.mogaks, selectedMogak: mogak, occurrences: occurrences, modalartID: modalartID, originFrame: originFrame, onExit: { [weak self] in self?.reloadSelectedModalart() }, from: self)
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    @objc private func modalartListButtonTapped() {
        guard !viewModel.isGuest else {
            coordinator?.presentLoginGate(from: self)
            return
        }
        coordinator?.presentModalartList(modalarts: viewModel.state.modalarts, onSelection: { [weak self] in self?.selectModalart(at: $0) }, onAdd: { [weak self] in self?.createModalart() }, from: self)
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
        coordinator?.routeToMogakEditing(mogak: mogak, from: self) { [weak self] in self?.reloadSelectedModalart() }
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
            openMogakDetail(viewModel.state.mogaks[mogakIndex], from: indexPath)
        } else if viewModel.state.needsTitle {
            coordinator?.presentMissingTitleNotice(from: self)
        } else if let modalartID = viewModel.state.selectedID {
            coordinator?.routeToMogakCreation(modalartID: modalartID, from: self) { [weak self] in self?.reloadSelectedModalart() }
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
