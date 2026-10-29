import UIKit
import SnapKit

final class MG2SelectModalartViewController: UIViewController {
    weak var coordinator: MG2ScheduleStartCoordinator?

    private let viewModel: MG2SelectModalartViewModel
    private let onJogaksAdded: () -> Void
    /// 목록이 올 때까지 자리 표시 행에 스켈레톤을 씌운다.
    private var isShowingPlaceholders = true
    private static let placeholderCount = 4

    private let headerView = MG2SheetHeaderView(title: "조각 가져오기")
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.apply(.footnote, color: DS.Color.sub)
        label.text = "어느 모다라트에서 오늘의 조각을 가져올까요?"
        label.textAlignment = .center
        label.numberOfLines = 0
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
        tableView.estimatedRowHeight = DS.Size.row + 8
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

    /// `.md-sheet`: padding 16 / 20, 블록 사이 gap 14.
    private func configureLayout() {
        view.addSubviews(headerView, subtitleLabel, tableView)

        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(14)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    /// 목록 자리만 스켈레톤으로 덮고 불러온 뒤 교차 페이드. 머리 · 안내 문구는 그대로 둔다.
    private func loadModalarts() {
        tableView.reloadData()
        view.layoutIfNeeded()
        tableView.showSkeletonBlocks()
        viewModel.loadModalarts { [weak self] result in
            guard let self else { return }
            // 화면 전환 중이면 끝난 뒤에 바꾼다 (전환과 겹쳐 움직이지 않게).
            afterTransition { [weak self] in
                guard let self else { return }
                tableView.hideSkeletonBlocks()
                UIView.transition(with: tableView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction]) {
                    self.isShowingPlaceholders = false
                    self.tableView.reloadData()
                }
                if case .failure(let error) = result { coordinator?.presentError(error, from: self) }
            }
        }
    }
}

extension MG2SelectModalartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isShowingPlaceholders ? Self.placeholderCount : viewModel.modalarts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MG2ModalartOptionCell.reuseIdentifier, for: indexPath) as? MG2ModalartOptionCell else { return UITableViewCell() }
        // 자리 표시 행은 빈 타일.
        guard !isShowingPlaceholders else { return cell }
        cell.configure(with: viewModel.modalarts[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        coordinator?.routeToJogakSelection(modalart: viewModel.modalarts[indexPath.row], modalarts: viewModel.modalarts, scheduledDate: viewModel.scheduledDate, from: self, onJogaksAdded: onJogaksAdded)
    }

}
