import UIKit
import SnapKit

final class SelectModalartViewController: UIViewController {
    weak var coordinator: MG2ScheduleStartCoordinator?

    private let viewModel: MG2JogakSelectionViewModel
    private let onJogaksAdded: () -> Void

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "내 모다라트"
        label.font = DesignSystemFont.semibold20L140.value
        label.textColor = .black
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            MG2ModalartOptionCell.self,
            forCellReuseIdentifier: MG2ModalartOptionCell.reuseIdentifier
        )
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        return tableView
    }()

    init(
        viewModel: MG2JogakSelectionViewModel,
        onJogaksAdded: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onJogaksAdded = onJogaksAdded
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        navigationItem.backButtonTitle = ""
        configureLayout()
        loadModalarts()
    }

    private func configureLayout() {
        view.addSubviews(titleLabel, tableView)

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(36)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func loadModalarts() {
        showLoading()
        viewModel.loadModalarts { [weak self] result in
            guard let self else { return }
            hideLoading()

            switch result {
            case .success:
                tableView.reloadData()
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }
}

extension SelectModalartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.state.modalarts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MG2ModalartOptionCell.reuseIdentifier,
            for: indexPath
        ) as? MG2ModalartOptionCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.state.modalarts[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        coordinator?.routeToJogakSelection(
            modalart: viewModel.state.modalarts[indexPath.row],
            viewModel: viewModel,
            from: self,
            onJogaksAdded: onJogaksAdded
        )
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}
