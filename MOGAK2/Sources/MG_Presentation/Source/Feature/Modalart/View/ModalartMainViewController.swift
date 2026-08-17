import SnapKit
import Then
import UIKit

final class ModalartMainViewController: UIViewController {
    weak var coordinator: MG2ModalartCoordinator?

    private let viewModel: MG2ModalartViewModel

    private let modalartNameLabel = UILabel().then {
        $0.font = DesignSystemFont.semibold20L140.value
        $0.textColor = DesignSystemColor.black.value
        $0.isUserInteractionEnabled = true
    }
    private lazy var showModalartListButton = UIButton().then {
        $0.setImage(UIImage(named: "downArrow"), for: .normal)
        $0.addTarget(self, action: #selector(showModalartList), for: .touchUpInside)
    }
    private lazy var modalartMenuButton = UIButton().then {
        $0.setImage(UIImage(named: "VerticalEllipsisBlack"), for: .normal)
        $0.accessibilityLabel = "모다라트 메뉴"
        $0.addTarget(self, action: #selector(showModalartActions), for: .touchUpInside)
    }
    private let modalartCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        $0.backgroundColor = DesignSystemColor.signatureBag.value
    }

    init(viewModel: MG2ModalartViewModel) {
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
        modalartNameLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(showModalartList))
        )
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
        modalartCollectionView.register(
            EmptyMogakCell.self,
            forCellWithReuseIdentifier: EmptyMogakCell.identifier
        )
        modalartCollectionView.register(
            MogakCell.self,
            forCellWithReuseIdentifier: MogakCell.identifier
        )
        modalartCollectionView.register(
            ModalartMainCell.self,
            forCellWithReuseIdentifier: ModalartMainCell.identifier
        )
        modalartCollectionView.delegate = self
        modalartCollectionView.dataSource = self
    }

    private func configureLayout() {
        view.addSubviews(
            modalartNameLabel,
            showModalartListButton,
            modalartMenuButton,
            modalartCollectionView
        )
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
        guard !viewModel.isGuest else {
            viewModel.load { [weak self] _ in
                self?.render()
            }
            return
        }
        performLoading(viewModel.load)
    }

    private func selectModalart(at index: Int) {
        guard viewModel.state.modalarts.indices.contains(index) else { return }
        performLoading { completion in
            self.viewModel.selectModalart(at: index, completion: completion)
        }
    }

    private func createModalart() {
        performLoading(viewModel.createModalart)
    }

    private func updateModalart(title: String, color: String) {
        guard viewModel.state.hasModalart else { return }
        performLoading { completion in
            self.viewModel.updateSelectedModalart(
                title: title,
                color: color,
                completion: completion
            )
        }
    }

    private func removeSelectedModalart() {
        guard viewModel.state.hasModalart else { return }
        performLoading(viewModel.deleteSelectedModalart)
    }

    private func reloadSelectedModalart() {
        guard viewModel.state.hasModalart else {
            render()
            return
        }
        performLoading(viewModel.reloadSelectedModalart)
    }

    private func performLoading(
        _ operation: (@escaping (Result<Void, Error>) -> Void) -> Void
    ) {
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
                coordinator?.routeToMogakDetail(
                    mogaks: viewModel.state.mogaks,
                    selectedMogak: mogak,
                    occurrences: occurrences,
                    modalartID: modalartID,
                    onExit: { [weak self] in self?.reloadSelectedModalart() },
                    from: self
                )
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    @objc private func showModalartList() {
        guard !viewModel.isGuest else {
            coordinator?.presentLoginGate(from: self)
            return
        }
        coordinator?.presentModalartList(
            modalarts: viewModel.state.modalarts,
            onSelection: { [weak self] in self?.selectModalart(at: $0) },
            onAdd: { [weak self] in self?.createModalart() },
            from: self
        )
    }

    @objc private func showModalartActions() {
        guard !viewModel.isGuest else {
            coordinator?.presentLoginGate(from: self)
            return
        }
        coordinator?.presentModalartActions(
            onAdd: { [weak self] in self?.createModalart() },
            onDelete: { [weak self] in self?.confirmModalartDeletion() },
            from: self
        )
    }

    private func confirmModalartDeletion() {
        guard viewModel.state.hasModalart else { return }
        coordinator?.presentDeleteConfirmation(
            onConfirm: { [weak self] in self?.removeSelectedModalart() },
            from: self
        )
    }

}

extension ModalartMainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        MG2MandalaGrid.itemCount
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.item == MG2MandalaGrid.centerIndex {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ModalartMainCell.identifier,
                for: indexPath
            ) as? ModalartMainCell else {
                return UICollectionViewCell()
            }
            cell.configure(
                title: viewModel.state.centerTitle,
                color: viewModel.state.centerColor
            )
            return cell
        }

        guard let mogakIndex = MG2MandalaGrid.contentIndex(for: indexPath.item),
              viewModel.state.mogaks.indices.contains(mogakIndex) else {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptyMogakCell.identifier,
                for: indexPath
            )
        }
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MogakCell.identifier,
            for: indexPath
        ) as? MogakCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModel.state.mogaks[mogakIndex], delegate: self)
        return cell
    }
}

extension ModalartMainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !viewModel.isGuest else {
            coordinator?.presentLoginGate(from: self)
            return
        }

        if indexPath.item == MG2MandalaGrid.centerIndex {
            coordinator?.presentModalartTitleEditor(
                title: viewModel.state.needsTitle ? nil : viewModel.state.title,
                color: viewModel.state.needsTitle ? "" : viewModel.state.color,
                onSubmit: { [weak self] title, color in
                    self?.updateModalart(title: title, color: color)
                },
                from: self
            )
            return
        }

        guard let mogakIndex = MG2MandalaGrid.contentIndex(for: indexPath.item) else { return }
        if viewModel.state.mogaks.indices.contains(mogakIndex) {
            openMogakDetail(viewModel.state.mogaks[mogakIndex])
        } else if viewModel.state.needsTitle {
            coordinator?.presentMissingTitleNotice(from: self)
        } else if let modalartID = viewModel.state.selectedID {
            coordinator?.routeToMogakCreation(
                modalartID: modalartID,
                delegate: self,
                from: self
            )
        }
    }
}

extension ModalartMainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        MG2MandalaGrid.sectionInsets
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        MG2MandalaGrid.minimumLineSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        MG2MandalaGrid.minimumInteritemSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        MG2MandalaGrid.itemSize(in: modalartCollectionView)
    }
}

extension ModalartMainViewController: MG2MogakSettingsDelegate {
    func mogakSettingsTapped(mogak: MG2ModalartMogakItemEntity) {
        guard !viewModel.isGuest else {
            coordinator?.presentLoginGate(from: self)
            return
        }
        coordinator?.routeToMogakEditing(mogak: mogak, delegate: self, from: self)
    }
}

extension ModalartMainViewController: MG2MogakFormDelegate {
    func mogakFormDidFinish() {
        reloadSelectedModalart()
    }
}
