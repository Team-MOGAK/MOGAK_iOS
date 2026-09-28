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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "희망/현직 직무 선택"
        label.textColor = .black
        label.font = UIFont.pretendard(.bold, size: 24)
        return label
    }()

    private let subLabel: UILabel = {
        let label = UILabel()
        label.text = "어떤 목표를 가진 모각러들과 함께 성장하고 싶으신가요?"
        label.textColor = DesignSystemColor.gray4.value
        label.font = UIFont.pretendard(.medium, size: 16)
        return label
    }()

    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        let placeholderAttributes = [NSAttributedString.Key.font: UIFont.pretendard(.bold, size: 16), NSAttributedString.Key.foregroundColor : DesignSystemColor.gray3.value]
        let placeholderText = "직무를 입력해주세요."
        search.delegate = self
        search.searchBarStyle = .minimal
        search.showsCancelButton = true
        search.searchTextField.backgroundColor = DesignSystemColor.gray2.value
        search.searchTextField.layer.cornerRadius = 10
        search.searchTextField.borderStyle = .none
        search.searchTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        search.searchTextField.textAlignment = .left
        return search
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()

    private lazy var nextButton: UIButton = {
        let button = MG2PrimaryActionButton()
        button.setTitle("다음", for: .normal)
        button.titleLabel?.textAlignment = .center
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
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .white

        configureNavigationBar()
        configureLabel()
        configureSearchBar()
        configureButton()
        configureTableView()

        loadJobs()
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = .gray
    }

    private func configureLabel() {
        view.addSubviews(titleLabel, subLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        subLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
    }

    private func configureSearchBar() {
        view.addSubview(searchBar)

        searchBar.snp.makeConstraints {
            $0.top.equalTo(subLabel.snp.bottom).offset(48)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.061)
        }
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(MG2NameCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.bottom.equalTo(nextButton.snp.top).offset(-12)
        }
    }

    private func configureButton() {
        view.addSubview(nextButton)

        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.061)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-23)
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
}
