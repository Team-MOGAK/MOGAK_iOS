//
//  ChooseRegionViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/13.
//

import UIKit
import SnapKit
import Alamofire

class ChooseRegionViewController: UIViewController {
    
    private let region = ["서울특별시", "경기도", "세종특별자치시","대전광역시","광주광역시","대구광역시","부산광역시","울산광역시","경상남도", "경상북도","전라남도","전라북도","충청남도","충청북도","강원도", "제주도", "독도/울릉도"]
    let network = UserNetwork()
    // checkButton 선택 셀 index
    private var previousIndexPath: IndexPath?
    private var selectedIndexPath: IndexPath?
    
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
    
    private lazy var nextButton : UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.backgroundColor = UIColor(hex: "BFC3D4")
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        button.addTarget(self, action: #selector(nextButtonIsClicked), for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.isUserInteractionEnabled = false
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
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
//        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = Bar
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
        tableView.register(RegionCell.self, forCellReuseIdentifier: "RegionCell")
        
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
            //            $0.height.equalTo(53)
            $0.height.equalToSuperview().multipliedBy(0.061)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        })
    }
    
    private func nextButtonIsOn() {
        nextButton.isUserInteractionEnabled = true
        nextButton.backgroundColor = UIColor(hex: "475FFD")
    }
    
    private func nextButtonIsOff() {
        nextButton.isUserInteractionEnabled = false
        nextButton.backgroundColor = UIColor(hex: "BFC3D4")
    }
    
    @objc private func nextButtonIsClicked() {
        
        let userData = UserInfoData(nickname: RegisterUserInfo.shared.nickName ?? "", job: RegisterUserInfo.shared.userJob ?? "" , address: RegisterUserInfo.shared.userRegion ?? "", email: RegisterUserInfo.shared.userEmail ?? "", multipartFile: "")
        print(#fileID, #function, #line, "- userData: \(userData)")
        print(#fileID, #function, #line, "- profileImage: \(RegisterUserInfo.shared.profileImage)")
        network.userJoin(userData, RegisterUserInfo.shared.profileImage) { result in
            print(#fileID, #function, #line, "- result:")
            switch result {
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error)")
            case .success(let success):
                print(#fileID, #function, #line, "- success: \(success)")
                var defaults = UserDefaults.standard //isFirstTime아닌지 체크하기
                defaults.set(false, forKey: "isFirstTime")
                let tabBarController = TabBarViewController()
                self.view.window?.rootViewController = tabBarController
            }
        }
//        registerUser()
        //        let mainVC = UINavigationController(rootViewController: TabBarViewController())
    }
    
}

extension ChooseRegionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return region.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCell") as? RegionCell else {return UITableViewCell()}
        let item = region[indexPath.row]
        cell.setName(item: item)
        cell.selectionStyle = .none
        
        // 이전에 선택한 셀과 현재 선택한 셀이 같을 때는 nextButton을 비활성화하고 리턴
        if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath {
            nextButtonIsOff()
            return cell
        }
        
        // 선택되지 않은 셀의 처리
        cell.setCheckOff()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexPath = selectedIndexPath  // 이전에 선택된 셀의 인덱스 저장
        selectedIndexPath = indexPath  // 선택된 셀의 인덱스 업데이트
        
        // 이전에 선택한 셀이 있으면 그 셀의 체크 해제
        if let previousIndexPath = previousIndexPath, let cell = tableView.cellForRow(at: previousIndexPath) as? RegionCell {
            cell.setCheckOff()
        }
        
        // 현재 선택한 셀의 체크 표시
        if let cell = tableView.cellForRow(at: indexPath) as? RegionCell {
            cell.setCheckOn()
        }
        
        // 선택된 셀이 있으면 nextButton 활성화, 선택된 셀이 없으면 비활성화
        if selectedIndexPath != nil {
            nextButtonIsOn()
        } else {
            nextButtonIsOff()
        }
        
        // 선택된 셀의 정보 가져오기
        if let cell = tableView.cellForRow(at: indexPath) as? RegionCell {
            if let region = cell.name.text {
                print("Selected cell's region: \(region)")
                RegisterUserInfo.shared.userRegion = region
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.bounds.height / 20
    }
    
    
}

//네트워크 코드
extension ChooseRegionViewController {
    func registerUser() {
        
        let userEmail = UserDefaults.standard.string(forKey: "userEmail")
        
        let url = ApiConstants.join
        
//        let parameters: Parameters = [
//            "nickname": "\(RegisterUserInfo.shared.nickName!)",
//            "job": "\(RegisterUserInfo.shared.userJob!)",
//            "address": "\(RegisterUserInfo.shared.userRegion!)",
//            "email": "\(userEmail!)"
//        ]
        
//        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
//            .responseJSON { response in
//                switch response.result {
//                case .success(let data):
//                    if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
//                        do {
//                            let decoder = JSONDecoder()
//                            let decodedData = try decoder.decode(JoinModel.self, from: jsonData)
//                            print("Decoded data: \(decodedData)")
//                            UserDefaults.standard.set(decodedData.userId, forKey: "userId")
//                            UserDefaults.standard.set(decodedData.nickname, forKey: "nickname")
//
//                            let mainVC = TabBarViewController()
//                            mainVC.modalPresentationStyle = .fullScreen
//                            self.present(mainVC, animated: true)
//                        } catch {
//                            print("Decoding error: \(error)")
//                        }
//                    } else {
//                        print("Invalid response data format")
//                    }
//                case .failure(let error):
//                    print("Error: \(error)")
//                    // 요청 실패 시 처리할 작업을 추가할 수 있습니다.
//                }
//            }
    }
    
    
}


