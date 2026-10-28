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
    weak var coordinator: MG2LoginCoordinator?

    init(viewModel: MG2ChooseJobViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let headerView = MG2ScreenHeaderView(title: "희망 · 현직 직무", subtitle: "어떤 모각러들과 함께 성장하고 싶나요?")

    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.delegate = self
        search.searchBarStyle = .minimal
        search.showsCancelButton = true
        search.tintColor = DS.Color.accentDeep
        search.searchTextField.backgroundColor = DS.Color.fill
        search.searchTextField.roundCorners(DS.Radius.field)
        search.searchTextField.clipsToBounds = true
        search.searchTextField.borderStyle = .none
        search.searchTextField.font = T.body.font
        search.searchTextField.textColor = DS.Color.ink
        search.searchTextField.attributedPlaceholder = NSAttributedString(string: "직무를 검색해 보세요", attributes: [.font: T.body.font, .foregroundColor: DS.Color.placeholder])
        search.searchTextField.textAlignment = .left
        return search
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
        button.setTitle(viewModel.isEditingMode ? "직무 저장" : "다음", for: .normal)
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
        configureSearchBar()
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
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
    }

    private func configureSearchBar() {
        view.addSubview(searchBar)

        searchBar.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet - 8)
            $0.height.equalTo(DS.Size.button + 8)
        }
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(MG2NameCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.bottom.equalTo(nextButton.snp.top).offset(-12)
        }
    }

    private func configureButton() {
        view.addSubview(nextButton)

        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.height.equalTo(DS.Size.button)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }

    private func renderSelection() {
        let hasSelection = !viewModel.selectedJob.isEmpty
        nextButton.isEnabled = hasSelection
    }

    private func updateJobSections(query: String) {
        viewModel.updateSections(matching: query)
        tableView.reloadData()
        renderSelection()
    }

    private func loadJobs() {
        showLoading()
        viewModel.loadJobs { [weak self] result in
            guard let self else { return }
            hideLoading()
            switch result {
            case .success:
                tableView.reloadData()
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

extension MG2ChooseJobViewController: UISearchBarDelegate {
    //외부 탭시 키보드 내림.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateJobSections(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        updateJobSections(query: "")
    }
}

extension MG2ChooseJobViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].jobs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MG2NameCell else { return UITableViewCell() }

        let job = viewModel.sections[indexPath.section].jobs[indexPath.row]
        cell.configure(name: job, isChecked: viewModel.selectedJob == job)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectJob(section: indexPath.section, row: indexPath.row)
        renderSelection()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sections[section].title
    }

    /// 목록 제목 (13 · 700 `ink-3`).
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        var content = header.defaultContentConfiguration()
        content.text = viewModel.sections[section].title
        content.textProperties.font = T.footnoteBold.font
        content.textProperties.color = DS.Color.ink3
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        header.contentConfiguration = content
        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = DS.Color.surface
        header.backgroundConfiguration = background
    }
}
