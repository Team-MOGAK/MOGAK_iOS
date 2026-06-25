//
//  ChooseRegionViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/13.
//

import UIKit
import SnapKit

class MG2ChooseRegionViewController: UIViewController {
    
    private let region = ["서울특별시", "경기도", "세종특별자치시","대전광역시","광주광역시","대구광역시","부산광역시","울산광역시","경상남도", "경상북도","전라남도","전라북도","충청남도","충청북도","강원도", "제주도", "독도/울릉도"]
    
    private let profileViewModel: MG2ProfileSetupViewModel
    weak var coordinator: MG2LoginCoordinator?

    init(profileViewModel: MG2ProfileSetupViewModel = DIContainer.shared.resolveRequired(MG2ProfileSetupViewModel.self)) {
        self.profileViewModel = profileViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
    
    //MARK: - 유저 등록
    @objc private func nextButtonIsClicked() {
        profileViewModel.joinUser(
            nickname: MG2Deps.app.userState.nickName ?? "",
            job: MG2Deps.app.userState.userJob ?? "",
            region: MG2Deps.app.userState.userRegion ?? "",
            email: MG2Deps.app.userState.userEmail ?? "",
            profileImage: MG2Deps.app.userState.profileImage
        ) { result in
            print(#fileID, #function, #line, "- result:")
            switch result {
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            case .success(let success):
                print(#fileID, #function, #line, "- success: \(success)")
                MG2LaunchStorage.setFirstTime(false)
                MG2LaunchStorage.setUserIsRegistered(true)
                MG2Deps.app.userState.userIsRegistered = true
                MG2Deps.app.userState.loginState = .login
            }
        }
    }
    
}

extension MG2ChooseRegionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return region.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MG2RegionCell") as? MG2RegionCell else {return UITableViewCell()}
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
        if let previousIndexPath = previousIndexPath, let cell = tableView.cellForRow(at: previousIndexPath) as? MG2RegionCell {
            cell.setCheckOff()
        }
        
        // 현재 선택한 셀의 체크 표시
        if let cell = tableView.cellForRow(at: indexPath) as? MG2RegionCell {
            cell.setCheckOn()
        }
        
        // 선택된 셀이 있으면 nextButton 활성화, 선택된 셀이 없으면 비활성화
        if selectedIndexPath != nil {
            nextButtonIsOn()
        } else {
            nextButtonIsOff()
        }
        
        // 선택된 셀의 정보 가져오기
        if let cell = tableView.cellForRow(at: indexPath) as? MG2RegionCell {
            if let region = cell.name.text {
                print("Selected cell's region: \(region)")
                MG2Deps.app.userState.userRegion = region
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.bounds.height / 20
    }

}
