//
//  JogakDetailViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/06.
//

import UIKit
import SnapKit

class JogakDetailViewController: UIViewController {
    
    private let statusButton = UIButton().then {
        $0.setTitle("성공", for: .normal)
        $0.setTitleColor(UIColor(hex: "009967"), for: .normal)
        $0.backgroundColor = UIColor(hex: "E7F9F3")
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = UIFont.pretendard(.semiBold, size: 14)
        $0.layer.cornerRadius = 10
    }
    
    private let categoryButton = UIButton().then {
        $0.setTitle("대외활동", for: .normal)
        $0.setTitleColor(UIColor(hex: "24252E"), for: .normal)
        $0.backgroundColor = UIColor(hex: "F1F3FA")
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = UIFont.pretendard(.semiBold, size: 14)
        $0.layer.cornerRadius = 10
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "기획 아티클 읽기"
        $0.textColor = UIColor(hex: "24252E")
        $0.font = UIFont.pretendard(.medium, size: 16)
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "2024.6.2 ~ / 월 수"
        $0.textColor = UIColor(hex: "6E707B")
        $0.font = UIFont.pretendard(.regular, size: 14)
    }
    
    private let grayView = UIView().then {
        $0.backgroundColor = UIColor(hex: "F1F3FA")
    }
    
    private let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = UIColor(hex: "F1F3FA")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.configureNavBar()
        self.configureTop()
        self.configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    private func configureNavBar() {
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "24252E")
        self.title = "성공 조각"
    }
    
    private func configureTop() {
        [statusButton, categoryButton, titleLabel, dateLabel].forEach({view.addSubview($0)})
        
        statusButton.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalToSuperview().multipliedBy(0.16)
            $0.height.equalToSuperview().multipliedBy(0.028)
        })
        
        categoryButton.snp.makeConstraints({
            $0.centerY.equalTo(self.statusButton.snp.centerY)
            $0.leading.equalTo(self.statusButton.snp.trailing).offset(8)
            $0.width.equalToSuperview().multipliedBy(0.16)
            $0.height.equalToSuperview().multipliedBy(0.028)
        })
        
        titleLabel.snp.makeConstraints({
            $0.top.equalTo(self.statusButton.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        })
        
        dateLabel.snp.makeConstraints({
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(20)
        })
    }
    
    private func configureTableView() {
        self.view.addSubview(grayView)
        grayView.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(JogakDetailCell.self, forCellReuseIdentifier: "JogakDetailCell")
        
        grayView.snp.makeConstraints({
            $0.top.equalTo(self.dateLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        })
        
        tableView.snp.makeConstraints({
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        })
    }
    
    func configureData(color: UIColor, status: String, category: String, title: String, textColor: UIColor) {
        self.statusButton.backgroundColor = color
        self.statusButton.setTitle(status, for: .normal)
        self.categoryButton.setTitle(category, for: .normal)
        self.titleLabel.text = title
        self.statusButton.setTitleColor(textColor, for: .normal)
    }
    
}

extension JogakDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "JogakDetailCell") as? JogakDetailCell else {return UITableViewCell()}
        cell.selectionStyle = .none
        cell.jogakDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.bounds.height / 5
    }
    
}

extension JogakDetailViewController: JogakDetailDelegate {
    func ellipsisTapped() {
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let actionRestart = UIAlertAction(title: "다시하기", style: .default)
        let actionDelete = UIAlertAction(title: "삭제하기", style: .destructive)
        let actionCancel = UIAlertAction(title: "취소", style: .cancel)
        
        actionSheet.addAction(actionRestart)
        actionSheet.addAction(actionDelete)
        actionSheet.addAction(actionCancel)
        
        actionCancel.setValue(UIColor(hex: "000000"), forKey: "titleTextColor")
        present(actionSheet, animated: true, completion: nil)
    }
    
    
}
