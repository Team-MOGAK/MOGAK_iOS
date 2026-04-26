//
//  ShowModalArtListModal.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/02.
//

import UIKit
import SnapKit

#if false
// Legacy MOGAK1 feature implementation (inactive after 1:1 migration to MOGAK2 MG_Presentation).

///모다라트 리스트 보여주는 모달
class ShowModalArtListModal: UIViewController {
    //MARK: - properties
    //모다라트 리스트들 -> 이 개수만큼 반복문을 돌려서
    var modalArtNameList: [ModalartList] = []
    
    //선택한 모다라트로 변경함
    var changeToSelectedModalart: ((_ modalartInfo: ModalartList, _ listIndex: Int) -> ())? = nil
    
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
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        modalArtNameList.append(ModalartList(id: 0, title: "모다라트 추가"))
//        modalArtNameList.append("모다라트 추가")
        configureLayout()
        dimmedBackGroundSetting()
        setUpTableView()
    }
    
    //MARK: - 뒤에 투명한 배경 탭 설정
    func dimmedBackGroundSetting() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmendBackgroundViewTapped(_:)))
        dimmedBackgroundView.addGestureRecognizer(dimmedTap)
        dimmedBackgroundView.isUserInteractionEnabled = true
    }
    
    //MARK: - 배경색 탭 했을 떄
    @objc private func dimmendBackgroundViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        self.dismiss(animated: false)
    }
    
    //MARK: - tableview setting
    func setUpTableView() {
        modalArtListTableView.register(ShowModalArtListCell.self, forCellReuseIdentifier: ShowModalArtListCell.identifier)
        modalArtListTableView.delegate = self
        modalArtListTableView.dataSource = self
    }
    
}

extension ShowModalArtListModal {
    //MARK: - 뷰들 레이아웃 잡기
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- selectedRow는?⭐️: \(indexPath.row)")
        let modalArtNum = indexPath.row //몇번쨰 모다라트인지
        let modalartInfo = modalArtNameList[modalArtNum]
        changeToSelectedModalart?(modalartInfo, modalArtNum)
        self.dismiss(animated: false)
    }

}

extension ShowModalArtListModal: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(#fileID, #function, #line, "- modalArtNamList count🔥: \(modalArtNameList.count)")
        return modalArtNameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = modalArtListTableView.dequeueReusableCell(withIdentifier: ShowModalArtListCell.identifier, for: indexPath) as? ShowModalArtListCell else { return UITableViewCell() }
        
        if indexPath.row == modalArtNameList.count - 1 { //맨 마지막 데이터일 경우 선이 안보이도록 설정
            cell.separatorInset = UIEdgeInsets(top: 0, left: modalArtListTableView.bounds.size.width, bottom: 0, right: 0);
        }
        cell.modalartName = modalArtNameList[indexPath.row].title ?? ""
//        print(#fileID, #function, #line, "- ⭐️: \(modalArtNameList[indexPath.row])")
        cell.configureLayout()
        cell.setUpLabel()
        return cell
    }
    
    
}

#endif
