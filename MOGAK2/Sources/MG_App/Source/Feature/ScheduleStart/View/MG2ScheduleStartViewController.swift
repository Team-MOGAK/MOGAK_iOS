import UIKit
import Combine

final class MG2ScheduleStartViewController: UIViewController {

    private let viewModel: MG2ScheduleStartViewModel
    private var cancellables = Set<AnyCancellable>()
    private var items: [ScheduleModalart] = []

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = MGFont.title()
        label.textColor = MGColor.textPrimary
        label.text = "모다라트"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = MGColor.background
        tableView.contentInset = UIEdgeInsets(top: MGSpacing.medium, left: 0, bottom: MGSpacing.large, right: 0)
        return tableView
    }()

    init(viewModel: MG2ScheduleStartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupTableView()
        bind()
        viewModel.onAppear()
    }

    private func setupLayout() {
        view.backgroundColor = MGColor.background

        view.addSubview(titleLabel)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: MGSpacing.large),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: MGSpacing.large),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -MGSpacing.large),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: MGSpacing.medium),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: MGSpacing.large),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -MGSpacing.large),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupTableView() {
        tableView.register(MG2ScheduleStartCell.self, forCellReuseIdentifier: MG2ScheduleStartCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    private func render(_ state: MG2ScheduleStartViewState) {
        switch state {
        case .idle, .loading:
            break
        case .loaded(let modalarts):
            items = modalarts
            tableView.reloadData()
        case .failed(let message):
            showError(message)
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension MG2ScheduleStartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MG2ScheduleStartCell.reuseIdentifier,
            for: indexPath
        ) as? MG2ScheduleStartCell else {
            return UITableViewCell()
        }

        cell.configure(with: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didTapModalart(id: items[indexPath.row].id)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        88
    }
}

final class MG2ScheduleStartCell: UITableViewCell {

    static let reuseIdentifier = "MG2ScheduleStartCell"

    private let cardView = MGCardContainerView()
    private let titleLabel = UILabel()
    private let colorLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        titleLabel.font = MGFont.body()
        titleLabel.textColor = MGColor.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        colorLabel.font = MGFont.caption()
        colorLabel.textColor = MGColor.textSecondary
        colorLabel.translatesAutoresizingMaskIntoConstraints = false

        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(colorLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: MGSpacing.small),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -MGSpacing.small),

            titleLabel.topAnchor.constraint(equalTo: cardView.contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor),

            colorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: MGSpacing.xSmall),
            colorLabel.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor),
            colorLabel.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor),
            colorLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.contentView.bottomAnchor)
        ])
    }

    func configure(with modalart: ScheduleModalart) {
        titleLabel.text = modalart.title
        colorLabel.text = modalart.color
    }
}
