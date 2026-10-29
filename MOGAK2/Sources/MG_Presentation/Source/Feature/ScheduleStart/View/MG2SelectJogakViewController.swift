import UIKit
import SnapKit

final class MG2SelectJogakViewController: UIViewController {
    weak var coordinator: MG2ScheduleStartCoordinator?

    private let viewModel: MG2SelectJogakViewModel
    private let onJogaksAdded: () -> Void
    private var expandedSections = Set<Int>()
    /// 고른 모다라트의 조각이 올 때까지 자리 표시 행에 스켈레톤을 씌운다.
    private var isShowingPlaceholders = false
    private static let placeholderCount = 4

    init(viewModel: MG2SelectJogakViewModel, onJogaksAdded: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onJogaksAdded = onJogaksAdded
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var modalartButton: UIButton = {
        let button = UIButton()
        button.setTitle("내 모다라트", for: .normal)
        button.titleLabel?.font = T.headline.font
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        // 긴 모다라트 이름은 한 줄 말줄임 (UIButton 기본값은 가운데 말줄임).
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.setTitleColor(DS.Color.ink, for: .normal)
        button.accessibilityHint = "다른 모다라트를 고를 수 있어요"
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        imageView.tintColor = DS.Color.ghost
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()

    private lazy var addButton: MG2PrimaryActionButton = {
        let button = MG2PrimaryActionButton()
        button.setTitle("오늘의 조각에 추가", for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MG2ExpandableMogakCell.self, forCellReuseIdentifier: MG2ExpandableMogakCell.reuseIdentifier)
        tableView.register(MG2SelectableJogakCell.self, forCellReuseIdentifier: MG2SelectableJogakCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        // 큰 글자에서 행이 늘어나도록 셀이 높이를 정한다 (최소 56 · 52).
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = DS.Size.row
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface
        applyStepNavigationBar()
        configureLayout()
        configureModalartMenu()
        selectModalart(viewModel.initialModalart)
    }

    private func configureLayout() {
        view.addSubviews(modalartButton, chevronImageView, tableView, addButton)

        modalartButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.height.greaterThanOrEqualTo(DS.Size.touch)
        }

        chevronImageView.snp.makeConstraints {
            $0.centerY.equalTo(modalartButton)
            $0.leading.equalTo(modalartButton.snp.trailing).offset(6)
            $0.trailing.lessThanOrEqualToSuperview().inset(DS.Space.sheet)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(modalartButton.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(addButton.snp.top).offset(-10)
        }

        addButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.sheet)
        }
    }

    private func configureModalartMenu() {
        let actions = viewModel.modalarts.map { modalart in UIAction(title: modalart.title) { [weak self] _ in self?.selectModalart(modalart) } }
        modalartButton.menu = UIMenu(children: actions)
    }

    private func selectModalart(_ modalart: MG2ModalartOption) {
        modalartButton.setTitle(modalart.title, for: .normal)
        loadSections(modalartID: modalart.id)
    }

    /// 목록 자리만 스켈레톤으로 덮고 고른 모다라트의 조각을 불러온 뒤 교차 페이드. 메뉴 버튼은 그대로 둔다.
    private func loadSections(modalartID: Int) {
        isShowingPlaceholders = true
        expandedSections.removeAll()
        tableView.reloadData()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.adjustedContentInset.top), animated: false)
        view.layoutIfNeeded()
        tableView.showSkeletonBlocks()
        viewModel.loadMogakSections(modalartID: modalartID) { [weak self] result in
            guard let self else { return }
            tableView.hideSkeletonBlocks()
            UIView.transition(with: tableView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction]) {
                self.isShowingPlaceholders = false
                self.tableView.reloadData()
            }

            // 실패하면 보이는 목록(앞 판)의 이름으로 되돌린다.
            modalartButton.setTitle((viewModel.selectedModalart ?? viewModel.initialModalart).title, for: .normal)
            switch result {
            case .success:
                updateAddButtonState()
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    @objc private func addButtonTapped() {
        guard viewModel.hasSelectedJogaks else { return }
        addButton.setLoading(true)
        viewModel.addSelectedJogaks { [weak self] result in
            guard let self else { return }
            addButton.setLoading(false)
            switch result {
            case .success:
                coordinator?.finishJogakSelection(from: self, onFinished: onJogaksAdded)
            case .failure(let error):
                tableView.reloadData()
                updateAddButtonState()
                // 실패 전까지 가져온 조각은 서버에 들어갔다. 시트를 닫지 않아도 홈은 새로 고친다.
                onJogaksAdded()
                coordinator?.presentError(error, from: self)
            }
        }
    }

    private func updateAddButtonState() {
        addButton.isEnabled = viewModel.hasSelectedJogaks
    }

    private func toggleSection(_ section: Int) {
        guard viewModel.sections.indices.contains(section) else { return }

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

        let jogakIndexPaths = viewModel.sections[section].jogaks.indices.map {
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
        } completion: { _ in headerCell?.isUserInteractionEnabled = true }
    }
}

extension MG2SelectJogakViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        isShowingPlaceholders ? Self.placeholderCount : viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !isShowingPlaceholders else { return 1 }
        let jogakCount = viewModel.sections[section].jogaks.count
        return expandedSections.contains(section) ? jogakCount + 1 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MG2ExpandableMogakCell.reuseIdentifier, for: indexPath) as? MG2ExpandableMogakCell else { return UITableViewCell() }
            // 불러오는 동안은 접힌 자리 표시 머리 줄.
            cell.configure(with: isShowingPlaceholders ? .placeholder : viewModel.sections[indexPath.section])
            cell.setExpanded(!isShowingPlaceholders && expandedSections.contains(indexPath.section))
            return cell
        }

        let jogakIndex = indexPath.row - 1
        guard viewModel.sections[indexPath.section].jogaks.indices.contains(jogakIndex) else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MG2SelectableJogakCell.reuseIdentifier, for: indexPath) as? MG2SelectableJogakCell else { return UITableViewCell() }

        let item = viewModel.sections[indexPath.section].jogaks[jogakIndex]
        cell.configure(with: item, isSelected: viewModel.isJogakSelected(item.id))
        cell.onSelection = { [weak self, weak cell] jogakID in
            guard let self else { return }
            cell?.setSelectedAppearance(viewModel.toggleJogakSelection(jogakID))
            updateAddButtonState()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else { return }
        toggleSection(indexPath.section)
    }
}
