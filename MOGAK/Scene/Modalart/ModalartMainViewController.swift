//
//  ModalartMainViewController.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/04.
//

import Foundation
import UIKit
import SnapKit

//MARK: - 모다라트 화면
class ModalartMainViewController: UIViewController {
    //MARK: - 임시 데이터들
//    var modalArtNameArr: [String] = ["내 모다라트"]
    var modalArtNameArr: [String] = ["김라영의 모다라트", "운동하기", "내 모다라트3"] //modalArtName만 String배열로 받고 지금 보여주는 모다라트가 몇번째 모다라트인지 알고 있어야 한다
    var nowShowModalArtNum: Int = 0 //현재 보여지는 모다라트의 번호
    var mogakCategory: [(String, String)] = [("운동", "10키로 감량1"), ("자기계발", "인생은 아름다워 읽기"),("운동", "10키로 감량2"), ("운동", "10키로 감량"), ("운동", "10키로 감량3"), ("운동", "10키로 감량4")]
//    var mogakCategory: [(String, String)] = []
//    var modalArtMainCellBgColor: String = "475FFD" //나중에 받아와서 변경할 에정
    var modalArtMainCellBgColor: String = "BFC3D4" //나중에 받아와서 변경할 에정
    
    private lazy var modalArtNameLabel: UILabel = {
        let label = UILabel()
        label.text = modalArtNameArr[nowShowModalArtNum] //데이터 받아오면 그 모다라트 이름으로 변경 필요
        label.font = DesignSystemFont.semibold20L140.value
        label.textColor = DesignSystemColor.black.value
        return label
    }()
    
    private lazy var showModalArtListBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "downArrow"), for: .normal)
        btn.addTarget(self, action: #selector(showModalartListTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var tacoBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "verticalEllipsisBlack"), for: .normal)
        btn.addTarget(self, action: #selector(tacoBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var modalArtCollectionView: UICollectionView = {
        print(#fileID, #function, #line, "- collectionview 생성⭐️")
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.backgroundColor = DesignSystemColor.signatureBag.value
        return collectionView
    }()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = DesignSystemColor.signatureBag.value
        collectionViewSetting()
        configureLayout()
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - 현재 생성된 모다라트 리스트 보여줌
    @objc private func showModalartListTapped() {
        print(#fileID, #function, #line, "- 모다라트 추가 버튼 탭")
        let showModalartListModalVC = ShowModalArtListModal()
        showModalartListModalVC.modalArtNameList = modalArtNameArr
        
        ///모다라트 리스트를 보여주는 모달에서 원하는 리스트를 선택했을 경우
        showModalartListModalVC.changeToSelectedModalart = { num, title in
            let hasModalArtNameChecking: Bool = title.prefix(6) != "내 모다라트" //모다라트 타이틀이 설정됬는지 체크
            let modalArtNameIsAddModalart: Bool = title == "모다라트 추가" //모다라트 추가 리스트를 클릭했는지 체크
            
            if hasModalArtNameChecking && !modalArtNameIsAddModalart { //모다라트 타이틀 설정됨
                self.mogakCategory = [("딴스", "bbbb"), ("aaaa", "aaaaa"),("bb", "cccc")]
                self.modalArtNameLabel.text = title
            }
            else if hasModalArtNameChecking && modalArtNameIsAddModalart { //모다라트 추가 클릭
                self.modalArtNameLabel.text = "내 모다라트\(num + 1)"
                self.modalArtNameArr.append("내 모다라트\(num + 1)")
                self.mogakCategory = []
            }
            else { //모다라트 타이틀 설정 안됨
                print(#fileID, #function, #line, "- 내 모다라트로 아직 타이틀 설정안됨")
                self.mogakCategory = []
                self.modalArtNameLabel.text = title
            }
            print(#fileID, #function, #line, "- modalArtNameArrcount🍀: \(self.modalArtNameArr.count)")
            self.nowShowModalArtNum = num
            self.modalArtCollectionView.reloadData()
        }
        
        showModalartListModalVC.modalPresentationStyle = .overFullScreen
        showModalartListModalVC.modalTransitionStyle = .crossDissolve
        self.present(showModalartListModalVC, animated: false)
    }
    
    //MARK: - 타코버튼 탭(모다라트 추가, 삭제하기 actionSheet)
    @objc private func tacoBtnTapped() {
        print(#fileID, #function, #line, "- 모다라트 추가 삭제버튼(타코버튼) 탭 ⭐️")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        ///모다라트 추가하기
        let addModalArtAction = UIAlertAction(title: "모다라트 추가", style: .default) { _ in
            // 모다라트를 계속적으로 추가할 수 있게 할 것인지
            let nextModalArtName: String = "내 모다라트" + String(self.modalArtNameArr.count + 1)
            self.modalArtNameArr.append(nextModalArtName)
            self.modalArtNameLabel.text = nextModalArtName
            self.nowShowModalArtNum = self.modalArtNameArr.count - 1
            self.mogakCategory = [("딴스", "bbbb"), ("뇨뇽", "aaaaa"),("냐냥", "cccc")]
            self.modalArtCollectionView.reloadData()
        }
        
        ///모다라트 삭제하기
        let deleteModalArtAction = UIAlertAction(title: "현 모다라트 삭제", style: .destructive) { _ in
            if self.modalArtNameArr.count == 1 { //현재 삭제하려고 하는 모다라트가 마지막 하나일 경우
                self.modalArtNameLabel.text = "내 모다라트"
                self.modalArtNameArr = ["내 모다라트"]
                self.nowShowModalArtNum = 0
                self.mogakCategory = []
            }
            else if self.nowShowModalArtNum == 0 { //현재 삭제하려고 하는 모다라트가 첫번째 모다라트일 경우 -> 그 다음 모다라트 보여주기
                self.modalArtNameArr.remove(at: self.nowShowModalArtNum)
                self.nowShowModalArtNum = self.nowShowModalArtNum
                self.modalArtNameLabel.text = self.modalArtNameArr[self.nowShowModalArtNum]
                self.mogakCategory = [] //여기서 데이터를 다시 불러와야 한다.
            }
            else { //기타 -> 앞에 모다라트가 있을꺼니까 바로 앞 모다라트 보여주기
                self.modalArtNameArr.remove(at: self.nowShowModalArtNum)
                self.nowShowModalArtNum = self.nowShowModalArtNum - 1
                self.modalArtNameLabel.text = self.modalArtNameArr[self.nowShowModalArtNum]
                self.mogakCategory = [] //여기서 데이터를 다시 불러와야 한다.
            }
            self.modalArtCollectionView.reloadData()
        }
        
        ///액션sheet취소
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            print(#fileID, #function, #line, "- <#comment#>")
            self.dismiss(animated: false)
        }
        
        actionSheet.addAction(addModalArtAction)
        actionSheet.addAction(deleteModalArtAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
    
    //MARK: - modalart collectionview 세팅
    func collectionViewSetting() {
        //cell등록
        modalArtCollectionView.register(EmptyMogakCell.self, forCellWithReuseIdentifier: EmptyMogakCell.identifier)
        modalArtCollectionView.register(MogakCell.self, forCellWithReuseIdentifier: MogakCell.identifier)
        modalArtCollectionView.register(ModalartMainCell.self, forCellWithReuseIdentifier: ModalartMainCell.identifier)
        
        //delegate, datasource를 사용할 viewcontroller설정
        modalArtCollectionView.delegate = self
        modalArtCollectionView.dataSource = self
    }

}

//MARK: - 모다라트VC 뷰들 레이아웃 잡기
extension ModalartMainViewController {
    func configureLayout() {
        self.view.addSubviews(modalArtNameLabel, showModalArtListBtn, tacoBtn, modalArtCollectionView)
        
        //모다라트 사이즈 설정
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let screenWidthSize = window.screen.bounds.width
        let modalArtWidthSize = screenWidthSize - 70 //모각 사이간격이 10, padding이 20
        
        //MARK: - 모다라트 이름 라벨 레이아웃
        modalArtNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
//            $0.top.equalToSuperview().offset(60)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        //MARK: - 사용자가 만들어놓은 모다라트 리스트 보기
        showModalArtListBtn.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.leading.equalTo(modalArtNameLabel.snp.trailing).offset(12)
            $0.centerY.equalTo(modalArtNameLabel.snp.centerY)
        }
        
        //MARK: - 타코버튼(모다라트 추가, 삭제하기 actionSheet)
        tacoBtn.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(modalArtNameLabel.snp.centerY)
        }
        
        modalArtCollectionView.snp.makeConstraints{
            $0.width.equalTo(modalArtWidthSize)
            $0.height.equalTo(520)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(modalArtNameLabel.snp.top).offset(50)
        }
    }
}

extension ModalartMainViewController: UICollectionViewDelegate {
    //이걸 통해서 어떤 모각이 선택되었는지를 알 수 있음
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- 선택된 아이템: \(indexPath.row)")
        
        guard let cellType = collectionView.cellForItem(at: indexPath)?.reuseIdentifier else { return }
        if cellType == EmptyMogakCell.identifier && modalArtNameArr[nowShowModalArtNum] == "내 모다라트" {
            print(#fileID, #function, #line, "- 아무것도 없는 모각 셀")
            if modalArtNameArr[nowShowModalArtNum] == "내 모다라트" {
                let bottomSheetVC = CustomBottomModalSheet()
                bottomSheetVC.bottomHeight = 200
                let bottomSheetView = NeedModalArtMainTitleModal()
                bottomSheetView.vc = bottomSheetVC
                bottomSheetVC.bottomModalSheetView = bottomSheetView
                bottomSheetVC.modalPresentationStyle = .overFullScreen
                bottomSheetVC.modalTransitionStyle = .crossDissolve
                self.present(bottomSheetVC, animated: true)
            } else {
                print(#fileID, #function, #line, "- 작은 모다라트 설정으로 이동")
            }
        }
        else if cellType == ModalartMainCell.identifier {
            print(#fileID, #function, #line, "- 모다라트 중앙 셀 설정")
            //ModalArtMainCell의 goalLableTitle을 여기서 가지고 올 수가 없기 때문에 모다라트 타이틀로 결정을 해야 한다 -> 즉, 모다라트 타이틀의 앞 여섯글자가 내 모다라트와 동일한 경우 아직 목표 설정이 안된것!
            //그러므로 모다라트의 이름이 절대 내 모다라트이면 안된다! -> 내 모다라트라는 이름으로 할 경우 alert을 띄워야 한다고 생각함
            let hasModalArtNameChecking: Bool = String(modalArtNameArr[nowShowModalArtNum].prefix(6)) != "내 모다라트"
            let bottomSheetVC = SetModalArtNameModalVC()

            bottomSheetVC.titleSetTextField.text = hasModalArtNameChecking ? modalArtNameArr[nowShowModalArtNum] : nil
            bottomSheetVC.isTitleSetUp = hasModalArtNameChecking ? true : false
            bottomSheetVC.titleBgColor = modalArtMainCellBgColor
            print(#fileID, #function, #line, "- modalArtTitle⭐️: \(modalArtNameArr[nowShowModalArtNum])")
            bottomSheetVC.changeMainMogak = { bgColor, modalartTitle in
                print(#fileID, #function, #line, "- 모다라트 중앙 모각 세팅🔥: \(bgColor)")
                print(#fileID, #function, #line, "- 모다라트 중앙 모각 세팅🔥: \(modalartTitle)")
                
                self.modalArtNameLabel.text = modalartTitle
                self.modalArtMainCellBgColor = bgColor
                self.modalArtNameArr[self.nowShowModalArtNum] = modalartTitle
                self.modalArtCollectionView.reloadItems(at: [indexPath])
            }
            bottomSheetVC.modalPresentationStyle = .overFullScreen
            bottomSheetVC.modalTransitionStyle = .crossDissolve
            
            self.present(bottomSheetVC, animated: true)
        }
    }
}

extension ModalartMainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //MARK: - 한 섹션에 몇개의 아이템이 들어갈지
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    //MARK: - 어떤 셀을 만들어줄 건지
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let emptyMogakCell = modalArtCollectionView.dequeueReusableCell(withReuseIdentifier: EmptyMogakCell.identifier, for: indexPath) as? EmptyMogakCell else { return UICollectionViewCell() }
        
        guard let mainMogakCell = modalArtCollectionView.dequeueReusableCell(withReuseIdentifier: ModalartMainCell.identifier, for: indexPath) as? ModalartMainCell else { return UICollectionViewCell() }
        
        guard let mogakCell = modalArtCollectionView.dequeueReusableCell(withReuseIdentifier: MogakCell.identifier, for: indexPath) as? MogakCell else { return UICollectionViewCell() }
        
        let row = indexPath.row
        
        ///4번재 row는 중앙 셀이므로 중앙 셀을 표시
        if(row == 4) {
            let hasModalArtNameChecking: Bool = String(modalArtNameArr[nowShowModalArtNum].prefix(6)) != "내 모다라트"
            mainMogakCell.mainBackgroundColor = hasModalArtNameChecking ? modalArtMainCellBgColor : "BFC3D4"
            print(#fileID, #function, #line, "- 내 모다라트 이름 확인:\(hasModalArtNameChecking)")
            mainMogakCell.mainLabelText = hasModalArtNameChecking ? modalArtNameArr[nowShowModalArtNum] : "큰 목표 \n추가"//
            mainMogakCell.cellDataSetting()
            return mainMogakCell
        } else { //그외에는 일반 셀
            return checkEmptyCell(row, mogakCell, emptyMogakCell)
        }
    }
    
    //MARK: - 중앙 셀을 기준으로 중앙 셀 앞에 있는 셀인지 뒤에 있는 셀인지 체크
    func checkEmptyCell(_ row: Int, _ mogakCell: MogakCell, _ emptyMogakCell: EmptyMogakCell) -> UICollectionViewCell {
        if (mogakCategory.count > row && row < 4) { //0, 1, 2, 3 row
            mogakCell.goalCategoryLabelText = mogakCategory[row].0
            mogakCell.goalContentLabelText = mogakCategory[row].1
            mogakCell.goalCategoryLabelBackgoundColor = "E8EBFE"
            mogakCell.goalCategoryLabelTextColor = "475FFD"
            mogakCell.cellDataSetting()
            return mogakCell
        } else if (mogakCategory.count > row - 1 && row > 4) { //5, 6, 7, 8 row
            mogakCell.goalCategoryLabelText = mogakCategory[row - 1].0
            mogakCell.goalContentLabelText = mogakCategory[row - 1].1
            mogakCell.goalCategoryLabelBackgoundColor = "E8EBFE"
            mogakCell.goalCategoryLabelTextColor = "475FFD"
            mogakCell.cellDataSetting()
            return mogakCell
        } else {
            return emptyMogakCell
        }
    }
    
}

//MARK: - 모다라트 collectionview flowlayout
extension ModalartMainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = self.modalArtCollectionView.frame.width / 3.0 - 10 //하나의 셀이 가지는 넓이의최소 크기
        let cellHeight: CGFloat = self.modalArtCollectionView.frame.height / 3.0 - 10//하나의 셀이 가지는 높이의 최소 크기
        return CGSizeMake(cellWidth, cellHeight)
    }
}
