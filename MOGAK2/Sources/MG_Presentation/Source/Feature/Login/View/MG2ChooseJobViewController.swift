//
//  MG2ChooseJobViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/11.
//

import UIKit
import SnapKit

final class MG2ChooseJobViewController: UIViewController {
    private let viewModel: MG2ChooseJobViewModel
    private var isShowingPlaceholders = false
    weak var coordinator: MG2LoginCoordinator?

    init(viewModel: MG2ChooseJobViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let headerView = MG2ScreenHeaderView(title: "희망 · 현직 직무", subtitle: "어떤 모각러들과 함께 성장하고 싶나요?")

    /// 직무 검색 (`.md-field`). 글자가 있으면 오른쪽 지우기 버튼으로 비운다.
    private lazy var searchField: MG2TextField = {
        let field = MG2TextField()
        field.placeholder = "직무를 검색해 보세요"
        field.accessibilityLabel = "직무 검색"
        field.returnKeyType = .search
        field.clearButtonMode = .never
        field.delegate = self
        field.addAction(UIAction { [weak self, weak field] _ in self?.updateJobSections(query: field?.text ?? "") }, for: .editingChanged)
        return field
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.sectionHeaderTopPadding = 8
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        return tableView
    }()

    private lazy var nextButton: UIButton = {
        let button = MG2PrimaryActionButton()
        button.setTitle(viewModel.isEditingMode ? "직무 저장" : "직무 정하고 계속하기", for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface

        configureNavigationBar()
        configureLabel()
        configureSearchField()
        configureButton()
        configureTableView()

        loadJobs()
    }

    private func configureNavigationBar() {
        applyStepNavigationBar()
    }

    private func configureLabel() {
        view.addSubview(headerView)

        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(DS.Space.sheet)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
        }
    }

    private func configureSearchField() {
        view.addSubview(searchField)

        searchField.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
        }
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(MG2NameCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.top.equalTo(searchField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
            $0.bottom.equalTo(nextButton.snp.top).offset(-12)
        }
    }

    private func configureButton() {
        view.addSubview(nextButton)

        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
            $0.height.equalTo(DS.Size.button)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }

    private func renderSelection() {
        let hasSelection = !viewModel.selectedJob.isEmpty
        nextButton.isEnabled = hasSelection
    }

    private func updateJobSections(query: String) {
        // 불러오는 중이면 다 온 뒤에 검색어로 거른다.
        guard !isShowingPlaceholders else { return }
        viewModel.updateSections(matching: query)
        tableView.reloadData()
        renderSelection()
    }

    /// 불러오는 동안 자리 표시 직무 줄을 칸마다 덩어리로 덮는다. 제목 · 검색칸 · 버튼은 그대로. 오면 겹쳐 바꾼다.
    private func loadJobs() {
        isShowingPlaceholders = true
        tableView.reloadData()
        view.layoutIfNeeded()
        tableView.showSkeletonBlocks()
        viewModel.loadJobs { [weak self] result in
            guard let self else { return }
            tableView.hideSkeletonBlocks()
            UIView.transition(with: tableView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction]) {
                self.isShowingPlaceholders = false
                self.viewModel.updateSections(matching: self.searchField.text ?? "")
                self.tableView.reloadData()
            }
            switch result {
            case .success:
                renderSelection()
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    @objc private func nextButtonTapped() {
        viewModel.submit { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(.continueRegistration(let draft)):
                coordinator?.routeToChooseRegion(draft: draft, from: self)
            case .success(.profileUpdated):
                coordinator?.routeBack(from: self)
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }
}

extension MG2ChooseJobViewController: UITextFieldDelegate {
    //외부 탭시 키보드 내림.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension MG2ChooseJobViewController: UITableViewDelegate, UITableViewDataSource {
    /// 불러오는 동안은 이름 없는 자리 표시 한 묶음.
    private var sections: [MG2JobSection] {
        isShowingPlaceholders ? [MG2JobSection(title: "", jobs: Array(repeating: "", count: 6))] : viewModel.sections
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].jobs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MG2NameCell else { return UITableViewCell() }

        let job = sections[indexPath.section].jobs[indexPath.row]
        cell.configure(name: job, isChecked: !isShowingPlaceholders && viewModel.selectedJob == job)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isShowingPlaceholders else { return }
        viewModel.selectJob(section: indexPath.section, row: indexPath.row)
        renderSelection()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        isShowingPlaceholders ? nil : sections[section].title
    }

    /// 목록 제목 (13 · 700 `ink-3`).
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        var content = header.defaultContentConfiguration()
        content.text = sections[section].title
        content.textProperties.font = T.footnoteBold.font
        content.textProperties.color = DS.Color.ink3
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        header.contentConfiguration = content
        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = DS.Color.surface
        header.backgroundConfiguration = background
    }
}
