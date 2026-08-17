import UIKit
import SnapKit

final class SelectJogakModal: UIViewController {
    weak var coordinator: MG2ScheduleStartCoordinator?

    private let viewModel: MG2JogakSelectionViewModel
    private let initialModalart: MG2ModalartOption?
    private let onJogaksAdded: () -> Void
    private var expandedSections = Set<Int>()

    init(
        viewModel: MG2JogakSelectionViewModel,
        initialModalart: MG2ModalartOption? = nil,
        onJogaksAdded: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.initialModalart = initialModalart
        self.onJogaksAdded = onJogaksAdded
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var modalartButton: UIButton = {
        let button = UIButton()
        button.setTitle("내 모다라트", for: .normal)
        button.titleLabel?.font = DesignSystemFont.semibold20L140.value
        button.setTitleColor(.black, for: .normal)
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        imageView.tintColor = UIColor(hex: "#6E707B")
        return imageView
    }()

    private lazy var addButton: MG2PrimaryActionButton = {
        let button = MG2PrimaryActionButton()
        button.setTitle("추가하기", for: .normal)
        button.addTarget(self, action: #selector(addJogaks), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            MG2ExpandableMogakCell.self,
            forCellReuseIdentifier: MG2ExpandableMogakCell.reuseIdentifier
        )
        tableView.register(
            MG2SelectableJogakCell.self,
            forCellReuseIdentifier: MG2SelectableJogakCell.reuseIdentifier
        )
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureLayout()
        loadModalarts()
    }

    private func configureLayout() {
        view.addSubviews(modalartButton, chevronImageView, tableView, addButton)

        modalartButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(36)
        }

        chevronImageView.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.centerY.equalTo(modalartButton)
            $0.leading.equalTo(modalartButton.snp.trailing).offset(12)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(modalartButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(addButton.snp.top).offset(-10)
        }

        addButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(48)
        }
    }

    private func loadModalarts() {
        if !viewModel.state.modalarts.isEmpty {
            configureLoadedModalarts()
            return
        }

        showLoading()
        viewModel.loadModalarts { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                configureLoadedModalarts()
            case .failure(let error):
                hideLoading()
                coordinator?.presentError(error, from: self)
            }
        }
    }

    private func configureLoadedModalarts() {
        configureModalartMenu()
        let modalarts = viewModel.state.modalarts
        guard let selected = initialModalart.flatMap({ initial in
            modalarts.first { $0.id == initial.id }
        }) ?? modalarts.first else {
            hideLoading()
            return
        }
        selectModalart(selected)
    }

    private func configureModalartMenu() {
        let actions = viewModel.state.modalarts.map { modalart in
            UIAction(title: modalart.title) { [weak self] _ in
                self?.selectModalart(modalart)
            }
        }
        modalartButton.menu = UIMenu(children: actions)
    }

    private func selectModalart(_ modalart: MG2ModalartOption) {
        modalartButton.setTitle(modalart.title, for: .normal)
        loadSections(modalartID: modalart.id)
    }

    private func loadSections(modalartID: Int) {
        showLoading()
        viewModel.loadMogakSections(modalartID: modalartID) { [weak self] result in
            guard let self else { return }
            hideLoading()

            switch result {
            case .success:
                modalartButton.setTitle(
                    viewModel.state.selectedModalart?.title,
                    for: .normal
                )
                tableView.reloadData()
                updateAddButtonState()
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    @objc private func addJogaks() {
        guard viewModel.hasSelectedJogaks else { return }
        showLoading()
        viewModel.addSelectedJogaks { [weak self] result in
            guard let self else { return }
            hideLoading()
            switch result {
            case .success:
                coordinator?.finishJogakSelection(
                    from: self,
                    onFinished: onJogaksAdded
                )
            case .failure(let error):
                tableView.reloadData()
                updateAddButtonState()
                coordinator?.presentError(error, from: self)
            }
        }
    }

    private func updateAddButtonState() {
        addButton.isEnabled = viewModel.hasSelectedJogaks
    }

    private func toggleSection(_ section: Int) {
        guard viewModel.state.sections.indices.contains(section) else { return }

        let isExpanding: Bool
        if expandedSections.contains(section) {
            expandedSections.remove(section)
            isExpanding = false
        } else {
            expandedSections.insert(section)
            isExpanding = true
        }

        let headerIndexPath = IndexPath(row: 0, section: section)
        let headerCell = tableView.cellForRow(at: headerIndexPath) as? MG2ExpandableMogakCell
        headerCell?.setExpanded(isExpanding)

        let jogakIndexPaths = viewModel.state.sections[section].jogaks.indices.map {
            IndexPath(row: $0 + 1, section: section)
        }
        guard !jogakIndexPaths.isEmpty else { return }

        headerCell?.isUserInteractionEnabled = false
        tableView.performBatchUpdates {
            if isExpanding {
                tableView.insertRows(at: jogakIndexPaths, with: .fade)
            } else {
                tableView.deleteRows(at: jogakIndexPaths, with: .fade)
            }
        } completion: { _ in
            headerCell?.isUserInteractionEnabled = true
        }
    }
}

extension SelectJogakModal: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.state.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let jogakCount = viewModel.state.sections[section].jogaks.count
        return expandedSections.contains(section) ? jogakCount + 1 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MG2ExpandableMogakCell.reuseIdentifier,
                for: indexPath
            ) as? MG2ExpandableMogakCell else {
                return UITableViewCell()
            }
            cell.configure(with: viewModel.state.sections[indexPath.section])
            cell.setExpanded(expandedSections.contains(indexPath.section))
            return cell
        }

        let jogakIndex = indexPath.row - 1
        guard viewModel.state.sections[indexPath.section].jogaks.indices.contains(jogakIndex) else {
            return UITableViewCell()
        }
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MG2SelectableJogakCell.reuseIdentifier,
            for: indexPath
        ) as? MG2SelectableJogakCell else {
            return UITableViewCell()
        }

        let item = viewModel.state.sections[indexPath.section].jogaks[jogakIndex]
        cell.configure(with: item, isSelected: viewModel.isJogakSelected(item.id))
        cell.onSelection = { [weak self, weak cell] jogakID in
            guard let self else { return }
            cell?.setSelectedAppearance(self.viewModel.toggleJogakSelection(jogakID))
            self.updateAddButtonState()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else { return }
        toggleSection(indexPath.section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row == 0 ? 60 : 40
    }
}
