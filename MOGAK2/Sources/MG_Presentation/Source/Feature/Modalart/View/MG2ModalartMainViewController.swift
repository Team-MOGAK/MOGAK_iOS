import SnapKit
import Then
import UIKit

final class MG2ModalartMainViewController: UIViewController {
    weak var coordinator: MG2ModalartCoordinator?

    private let viewModel: MG2ModalartMainViewModel

    private let modalartNameLabel = UILabel().then {
        $0.font = DesignSystemFont.semibold20L140.value
        $0.textColor = DesignSystemColor.black.value
        $0.isUserInteractionEnabled = true
    }
    private lazy var showModalartListButton = UIButton().then {
        $0.setImage(UIImage(named: "downArrow"), for: .normal)
        $0.addTarget(self, action: #selector(modalartListButtonTapped), for: .touchUpInside)
    }
    private lazy var modalartMenuButton = UIButton().then {
        $0.setImage(UIImage(named: "VerticalEllipsisBlack"), for: .normal)
        $0.accessibilityLabel = "모다라트 메뉴"
        $0.addTarget(self, action: #selector(modalartMenuButtonTapped), for: .touchUpInside)
    }
    private let modalartCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = DesignSystemColor.signatureBag.value
    }

    init(viewModel: MG2ModalartMainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystemColor.signatureBag.value
        configureCollectionView()
        configureLayout()
        modalartNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(modalartListButtonTapped)))
        loadModalart()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
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
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        showModalartListButton.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.leading.equalTo(modalartNameLabel.snp.trailing).offset(12)
            $0.centerY.equalTo(modalartNameLabel)
        }
        modalartMenuButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(modalartNameLabel)
        }
        modalartCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(520)
            $0.centerX.centerY.equalToSuperview()
        }
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

    private func openMogakDetail(_ mogak: MG2ModalartMogakItemEntity) {
        showLoading()
        view.isUserInteractionEnabled = false
        viewModel.loadOccurrences(for: mogak) { [weak self] result in
            guard let self else { return }
            hideLoading()
            view.isUserInteractionEnabled = true
            switch result {
            case .success(let occurrences):
                guard let modalartID = viewModel.state.selectedID else { return }
                coordinator?.routeToMogakDetail(mogaks: viewModel.state.mogaks, selectedMogak: mogak, occurrences: occurrences, modalartID: modalartID, onExit: { [weak self] in self?.reloadSelectedModalart() }, from: self)
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
            cell.configure(title: viewModel.state.centerTitle, color: viewModel.state.centerColor)
            return cell
        }

        guard let mogakIndex = MG2MandalaGrid.contentIndex(for: indexPath.item), viewModel.state.mogaks.indices.contains(mogakIndex) else { return collectionView.dequeueReusableCell(withReuseIdentifier: MG2EmptyMogakCell.identifier, for: indexPath) }
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
            coordinator?.routeToMogakCreation(modalartID: modalartID, from: self) { [weak self] in self?.reloadSelectedModalart() }
        }
    }
}

extension MG2ModalartMainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        MG2MandalaGrid.sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        MG2MandalaGrid.minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        MG2MandalaGrid.minimumInteritemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        MG2MandalaGrid.itemSize(in: modalartCollectionView)
    }
}
