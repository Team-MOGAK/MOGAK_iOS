//
//  ChooseJobViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/11.
//

import UIKit
import SnapKit

final class MG2ChooseJobViewController: UIViewController {
    private let profileViewModel: MG2ProfileSetupViewModel
    private let mode: MG2ProfileSetupMode
    weak var coordinator: MG2LoginCoordinator?

    init(
        mode: MG2ProfileSetupMode = .registration,
        profileViewModel: MG2ProfileSetupViewModel
    ) {
        self.mode = mode
        self.profileViewModel = profileViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = "희망/현직 직무 선택"
        label.textColor = .black
        label.font = UIFont.pretendard(.bold, size: 24)
        return label
    }()
    
    private let subLabel : UILabel = {
        let label = UILabel()
        label.text = "어떤 목표를 가진 모각러들과 함께 성장하고 싶으신가요?"
        label.textColor = UIColor(hex: "808497")
        label.font = UIFont.pretendard(.medium, size: 16)
        return label
    }()
    
    private lazy var searchBar : UISearchBar = {
        let search = UISearchBar()
        let placeholderAttributes = [NSAttributedString.Key.font: UIFont.pretendard(.bold, size: 16), NSAttributedString.Key.foregroundColor : UIColor(hex: "BFC3D4")]
        let placeholderText = "직무를 입력해주세요."
        search.delegate = self
        search.searchBarStyle = .minimal
        search.showsCancelButton = true
        search.searchTextField.backgroundColor = UIColor(hex: "EEF0F8")
        search.searchTextField.layer.cornerRadius = 10
        search.searchTextField.borderStyle = .none
        search.searchTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        search.searchTextField.textAlignment = .left
        return search
    }()
    
    private let tableView : UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = MG2PrimaryActionButton()
        button.setTitle("다음", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(nextButtonIsClicked), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .white
        
        self.configureNavBar()
        self.configureLabel()
        self.configureSearchBar()
        self.configureButton()
        self.configureTableView()
        
        loadJobs()
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .gray
    }
    
    private func configureLabel() {
        self.view.addSubviews(titleLabel, subLabel)
        
        titleLabel.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(20)
        })
        
        subLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        })
    }
    
    private func configureSearchBar() {
        self.view.addSubview(searchBar)
        
        searchBar.snp.makeConstraints({
            $0.top.equalTo(subLabel.snp.bottom).offset(48)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.061)
        })
        
    }
    
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(MG2NameCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints({
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.bottom.equalTo(nextButton.snp.top).offset(-12)
        })
    }
    
    private func configureButton() {
        self.view.addSubview(nextButton)
        
        nextButton.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.061)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-23)
        })
    }
    
    private func renderSelection() {
        let hasSelection = !profileViewModel.state.selectedJob.isEmpty
        nextButton.isEnabled = hasSelection
    }

    private func updateJobSections(query: String) {
        profileViewModel.updateJobSections(matching: query)
        tableView.reloadData()
        renderSelection()
    }

    private func loadJobs() {
        showLoading()
        profileViewModel.loadJobs { [weak self] result in
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
    
    @objc private func nextButtonIsClicked() {
        profileViewModel.submitSelectedJob(mode: mode) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(.selectedForRegistration):
                coordinator?.routeToChooseRegion(from: self)
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
    // 리턴 키 입력 시 키보드 내림
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        profileViewModel.state.jobSections.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        profileViewModel.state.jobSections[section].jobs.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MG2NameCell else {
            return UITableViewCell()
        }

        let job = profileViewModel.state.jobSections[indexPath.section].jobs[indexPath.row]
        cell.configure(name: job, isChecked: profileViewModel.state.selectedJob == job)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        profileViewModel.selectJob(section: indexPath.section, row: indexPath.row)
        renderSelection()
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        profileViewModel.state.jobSections[section].title
    }
}
