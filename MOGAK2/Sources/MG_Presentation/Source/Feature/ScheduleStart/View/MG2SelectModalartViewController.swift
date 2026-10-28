import UIKit
import SnapKit

final class MG2SelectModalartViewController: UIViewController {
    weak var coordinator: MG2ScheduleStartCoordinator?

    private let viewModel: MG2SelectModalartViewModel
    private let onJogaksAdded: () -> Void

    private let headerView = MG2SheetHeaderView(title: "조각 가져오기")
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.apply(.footnote, color: DS.Color.sub)
        label.text = "어느 모다라트에서 오늘의 조각을 가져올까요?"
        label.textAlignment = .center
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MG2ModalartOptionCell.self, forCellReuseIdentifier: MG2ModalartOptionCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        return tableView
    }()

    init(viewModel: MG2SelectModalartViewModel, onJogaksAdded: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onJogaksAdded = onJogaksAdded
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface
        navigationController?.navigationBar.tintColor = DS.Color.ink
        navigationItem.backButtonDisplayMode = .minimal
        headerView.onClose = { [weak self] in
            guard let self else { return }
            coordinator?.closeJogakSelection(from: self)
        }
        configureLayout()
        loadModalarts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func configureLayout() {
        view.addSubviews(headerView, subtitleLabel, tableView)

        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(14)
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

extension MG2SelectModalartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.modalarts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MG2ModalartOptionCell.reuseIdentifier, for: indexPath) as? MG2ModalartOptionCell else { return UITableViewCell() }
        cell.configure(with: viewModel.modalarts[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        coordinator?.routeToJogakSelection(modalart: viewModel.modalarts[indexPath.row], modalarts: viewModel.modalarts, scheduledDate: viewModel.scheduledDate, from: self, onJogaksAdded: onJogaksAdded)
    }

}
