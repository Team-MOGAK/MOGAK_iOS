import UIKit
import SnapKit
import ExpyTableView

final class SelectJogakModal: UIViewController {
    weak var coordinator: MG2ScheduleStartCoordinator?

    private let viewModel: MG2JogakSelectionViewModel
    private let initialModalart: MG2ModalartOption?
    private let onJogaksAdded: () -> Void

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

    private lazy var tableView: ExpyTableView = {
        let tableView = ExpyTableView()
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
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
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
}

extension SelectJogakModal: ExpyTableViewDelegate, ExpyTableViewDataSource {
    nonisolated func tableView(
        _ tableView: ExpyTableView,
        expyState state: ExpyState,
        changeForSection section: Int
    ) {}

    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        !viewModel.state.sections[section].jogaks.isEmpty
    }

    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MG2ExpandableMogakCell.reuseIdentifier
        ) as? MG2ExpandableMogakCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.state.sections[section])
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.state.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.state.sections[section].jogaks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MG2SelectableJogakCell.reuseIdentifier,
            for: indexPath
        ) as? MG2SelectableJogakCell else {
            return UITableViewCell()
        }

        let item = viewModel.state.sections[indexPath.section].jogaks[indexPath.row]
        cell.configure(with: item, isSelected: viewModel.isJogakSelected(item.id))
        cell.onSelection = { [weak self, weak cell] jogakID in
            guard let self else { return }
            cell?.setSelectedAppearance(self.viewModel.toggleJogakSelection(jogakID))
            self.updateAddButtonState()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
}
