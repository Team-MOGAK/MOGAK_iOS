//
//  ShowModalArtListModal.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/02.
//

import UIKit
import SnapKit

///모다라트 리스트 보여주는 모달
class ShowModalArtListModal: UIViewController {
    //MARK: - properties
    //모다라트 리스트들 -> 이 개수만큼 반복문을 돌려서
    var modalArtNameList: [String] = []
    private var dimmedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        return view
    }()
    
    private var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemColor.white.value
        view.layer.cornerRadius = 15
        
        return view
    }()
    
    var modalArtListTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 15
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        dimmedBackGroundSetting()
        setUpTableView()
    }
    
    func dimmedBackGroundSetting() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmendBackgroundViewTapped(_:)))
        dimmedBackgroundView.addGestureRecognizer(dimmedTap)
        dimmedBackgroundView.isUserInteractionEnabled = true
    }
    
    @objc private func dimmendBackgroundViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        self.dismiss(animated: false)
    }
    
    func setUpTableView() {
        modalArtListTableView.register(ShowModalArtListCell.self, forCellReuseIdentifier: ShowModalArtListCell.identifier)
        modalArtListTableView.delegate = self
        modalArtListTableView.dataSource = self
    }
    
}

extension ShowModalArtListModal {
    func configureLayout() {
        self.view.addSubviews(dimmedBackgroundView, mainView)
        self.mainView.addSubview(modalArtListTableView)
        
        dimmedBackgroundView.alpha = 0.7
        
        dimmedBackgroundView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        
        mainView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(107)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(modalArtNameList.count * 53)
        }
        
        modalArtListTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
    }
}

extension ShowModalArtListModal: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53
    }

}

extension ShowModalArtListModal: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(#fileID, #function, #line, "- modalArtNamList count🔥: \(modalArtNameList.count)")
        return modalArtNameList.count
//        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = modalArtListTableView.dequeueReusableCell(withIdentifier: ShowModalArtListCell.identifier, for: indexPath) as? ShowModalArtListCell else { return UITableViewCell() }
        
        if indexPath.row == modalArtNameList.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: modalArtListTableView.bounds.size.width, bottom: 0, right: 0);
        }
        cell.modalartName = modalArtNameList[indexPath.row]
        print(#fileID, #function, #line, "- ⭐️: \(modalArtNameList[indexPath.row])")
        cell.configureLayout()
        cell.setUpLabel()
        return cell
    }
    
    
}
