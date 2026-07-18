//
//  ChooseRegionViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/13.
//

import UIKit
import SnapKit

final class MG2ChooseRegionViewController: UIViewController {
    weak var coordinator: MG2LoginCoordinator?
    private let profileViewModel: MG2ProfileSetupViewModel
    init(profileViewModel: MG2ProfileSetupViewModel) {
        self.profileViewModel = profileViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let mogakLabel : UILabel = {
        let label = UILabel()
        label.text = "거주지 선택"
        label.font = UIFont.pretendard(.bold, size: 24)
        label.textColor = .black
        return label
    }()
    
    private let subLabel : UILabel = {
        let label = UILabel()
        label.text = "나와 가장 가까운 모각러들과 함께 성장해봐요.\n현재는 시/도까지만 선택 가능해요."
        label.font = UIFont.pretendard(.medium, size: 16)
        label.numberOfLines = 2
        label.textColor = UIColor(hex: "808497")
        return label
    }()
    
    private let tableView : UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = MG2PrimaryActionButton()
        button.setTitle("완료", for: .normal)
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
        self.configureButton()
        self.configureTableView()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .gray
    }
    
    private func configureLabel() {
        self.view.addSubviews(mogakLabel, subLabel)
        
        mogakLabel.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(20)
        })
        
        subLabel.snp.makeConstraints({
            $0.top.equalTo(mogakLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        })
        
    }
    
    private func configureTableView() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MG2RegionCell.self, forCellReuseIdentifier: "MG2RegionCell")
        
        tableView.snp.makeConstraints({
            $0.top.equalTo(self.subLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(self.nextButton.snp.top).offset(-8)
        })
    }
    
    
    private func configureButton() {
        self.view.addSubview(nextButton)
        
        nextButton.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.061)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        })
    }
    
    private func renderSelection() {
        let hasSelection = !profileViewModel.state.selectedRegion.isEmpty
        nextButton.isEnabled = hasSelection
    }
    
    //MARK: - 유저 등록
    @objc private func nextButtonIsClicked() {
        profileViewModel.joinUser { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            case .success:
                break
            }
        }
    }
    
}

extension MG2ChooseRegionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        profileViewModel.availableRegions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MG2RegionCell") as? MG2RegionCell else {return UITableViewCell()}
        let item = profileViewModel.availableRegions[indexPath.row]
        cell.configure(name: item, isChecked: item == profileViewModel.state.selectedRegion)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        profileViewModel.selectRegion(at: indexPath.row)
        renderSelection()
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.bounds.height / 20
    }

}
