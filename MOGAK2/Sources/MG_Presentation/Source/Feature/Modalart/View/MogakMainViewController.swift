import SnapKit
import Then
import UIKit

final class MogakMainViewController: UIViewController {
    weak var coordinator: MG2ModalartCoordinator?
    var onExit: (() -> Void)?

    private let viewModel: MG2MogakDetailViewModel

    private lazy var deleteButton = UIBarButtonItem(
        title: "삭제",
        style: .plain,
        target: self,
        action: #selector(deleteSelectedMogak)
    ).then {
        $0.tintColor = .systemRed
        $0.accessibilityLabel = "선택한 세부목표 삭제"
    }
    private let mogakListCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        ($0.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        $0.backgroundColor = DesignSystemColor.signatureBag.value
        $0.showsHorizontalScrollIndicator = false
    }
    private let jogakCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        $0.backgroundColor = DesignSystemColor.signatureBag.value
    }

    init(viewModel: MG2MogakDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystemColor.signatureBag.value
        configureLayout()
        configureCollectionViews()
        if viewModel.hasRoutineOccurrences {
            performLoading(viewModel.loadRoutineDays)
        } else {
            render()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "세부목표"
        updateDeleteButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            onExit?()
        }
    }

    private func configureLayout() {
        view.addSubviews(mogakListCollectionView, jogakCollectionView)
        mogakListCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        jogakCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(520)
            $0.centerX.centerY.equalToSuperview()
        }
    }

    private func configureCollectionViews() {
        mogakListCollectionView.register(
            MogakListCell.self,
            forCellWithReuseIdentifier: MogakListCell.identifier
        )
        mogakListCollectionView.dataSource = self
        mogakListCollectionView.delegate = self

        jogakCollectionView.register(
            EmptyJogakCell.self,
            forCellWithReuseIdentifier: EmptyJogakCell.identifier
        )
        jogakCollectionView.register(
            ModalartMainCell.self,
            forCellWithReuseIdentifier: ModalartMainCell.identifier
        )
        jogakCollectionView.register(
            JogakCell.self,
            forCellWithReuseIdentifier: JogakCell.identifier
        )
        jogakCollectionView.register(
            IsRoutineJogakCell.self,
            forCellWithReuseIdentifier: IsRoutineJogakCell.identifier
        )
        jogakCollectionView.dataSource = self
        jogakCollectionView.delegate = self
    }

    private func render() {
        mogakListCollectionView.reloadData()
        jogakCollectionView.reloadData()
        updateDeleteButton()

        guard let index = viewModel.state.mogaks.firstIndex(where: {
            $0.mogakId == viewModel.state.selectedMogakID
        }) else { return }
        mogakListCollectionView.selectItem(
            at: IndexPath(item: index, section: 0),
            animated: false,
            scrollPosition: .centeredHorizontally
        )
    }

    private func updateDeleteButton() {
        navigationItem.rightBarButtonItem = viewModel.state.selectedMogak == nil
            ? nil
            : deleteButton
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

    private func removeSelectedMogak() {
        guard viewModel.state.selectedMogak != nil else { return }
        showLoading()
        view.isUserInteractionEnabled = false
        viewModel.deleteSelectedMogak { [weak self] result in
            guard let self else { return }
            hideLoading()
            view.isUserInteractionEnabled = true
            switch result {
            case .success(.reloaded):
                render()
            case .success(.noMogaksRemaining):
                render()
                coordinator?.presentNoMogaksRemaining(from: self)
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    private func removeJogak(id: Int) {
        performLoading { completion in
            self.viewModel.deleteJogak(id: id, completion: completion)
        }
    }

    private func showJogakActions(for occurrence: MG2JogakOccurrenceEntity) {
        showLoading()
        view.isUserInteractionEnabled = false
        viewModel.loadJogakActionContext(for: occurrence) { [weak self] result in
            guard let self else { return }
            hideLoading()
            view.isUserInteractionEnabled = true
            switch result {
            case .success(let context):
                coordinator?.presentJogakActions(
                    viewData: context.summary,
                    onEdit: { [weak self] in
                        guard let self else { return }
                        coordinator?.routeToJogakEditing(
                            jogak: context.detail,
                            delegate: self,
                            from: self
                        )
                    },
                    onDelete: { [weak self] in
                        guard let self else { return }
                        coordinator?.presentDeleteConfirmation(
                            onConfirm: { [weak self] in
                                self?.removeJogak(id: context.detail.jogakID)
                            },
                            from: self
                        )
                    },
                    from: self
                )
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    @objc private func deleteSelectedMogak() {
        guard let selectedMogak = viewModel.state.selectedMogak else { return }
        coordinator?.presentDeleteAction(
            title: selectedMogak.title,
            message: "선택한 세부목표를 삭제할까요?",
            onConfirm: { [weak self] in self?.removeSelectedMogak() },
            from: self
        )
    }
}

extension MogakMainViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == mogakListCollectionView {
            return viewModel.state.mogaks.count
        }
        return viewModel.state.selectedMogak == nil ? 0 : MG2MandalaGrid.itemCount
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == mogakListCollectionView {
            let reusableCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MogakListCell.identifier,
                for: indexPath
            )
            guard let cell = reusableCell as? MogakListCell,
                  viewModel.state.mogaks.indices.contains(indexPath.item) else {
                return reusableCell
            }
            cell.configure(title: viewModel.state.mogaks[indexPath.item].category.name)
            return cell
        }

        guard let selectedMogak = viewModel.state.selectedMogak else {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptyJogakCell.identifier,
                for: indexPath
            )
        }
        if indexPath.item == MG2MandalaGrid.centerIndex {
            let reusableCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ModalartMainCell.identifier,
                for: indexPath
            )
            guard let cell = reusableCell as? ModalartMainCell else { return reusableCell }
            cell.configure(
                title: selectedMogak.title,
                color: selectedMogak.color ?? DesignSystemPalette.signatureHex
            )
            return cell
        }

        guard let jogakIndex = MG2MandalaGrid.contentIndex(for: indexPath.item),
              viewModel.state.occurrences.indices.contains(jogakIndex) else {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptyJogakCell.identifier,
                for: indexPath
            )
        }
        let occurrence = viewModel.state.occurrences[jogakIndex]
        if occurrence.isRoutine {
            let reusableCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: IsRoutineJogakCell.identifier,
                for: indexPath
            )
            guard let cell = reusableCell as? IsRoutineJogakCell else { return reusableCell }
            cell.configure(
                badgeText: viewModel.routineDaysText(for: occurrence),
                title: occurrence.title,
                color: selectedMogak.color ?? DesignSystemPalette.signatureHex
            )
            return cell
        }

        let reusableCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: JogakCell.identifier,
            for: indexPath
        )
        guard let cell = reusableCell as? JogakCell else { return reusableCell }
        cell.configure(title: occurrence.title)
        return cell
    }
}

extension MogakMainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mogakListCollectionView {
            guard viewModel.state.mogaks.indices.contains(indexPath.item) else { return }
            performLoading { completion in
                self.viewModel.selectMogak(at: indexPath.item, completion: completion)
            }
            return
        }

        guard let selectedMogak = viewModel.state.selectedMogak else { return }
        if indexPath.item == MG2MandalaGrid.centerIndex {
            coordinator?.presentMogakActions(
                mogak: selectedMogak,
                onEdit: { [weak self] in
                    guard let self else { return }
                    coordinator?.routeToMogakEditing(
                        mogak: selectedMogak,
                        delegate: self,
                        from: self
                    )
                },
                onDelete: { [weak self] in
                    guard let self else { return }
                    coordinator?.presentDeleteConfirmation(
                        onConfirm: { [weak self] in self?.removeSelectedMogak() },
                        from: self
                    )
                },
                from: self
            )
            return
        }

        guard let jogakIndex = MG2MandalaGrid.contentIndex(for: indexPath.item) else { return }
        guard viewModel.state.occurrences.indices.contains(jogakIndex) else {
            coordinator?.routeToJogakCreation(
                mogak: selectedMogak,
                delegate: self,
                from: self
            )
            return
        }

        showJogakActions(for: viewModel.state.occurrences[jogakIndex])
    }
}

extension MogakMainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == mogakListCollectionView {
            let title = viewModel.state.mogaks[indexPath.item].category.name as NSString
            let size = title.size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
            return CGSize(width: size.width + 30, height: 30)
        }
        return MG2MandalaGrid.itemSize(in: jogakCollectionView)
    }

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
}

extension MogakMainViewController: MG2JogakFormDelegate {
    func jogakFormDidFinish() {
        guard viewModel.state.selectedMogak != nil else {
            render()
            return
        }
        performLoading(viewModel.reloadOccurrences)
    }
}

extension MogakMainViewController: MG2MogakFormDelegate {
    func mogakFormDidFinish() {
        performLoading(viewModel.reloadMogaks)
    }
}
