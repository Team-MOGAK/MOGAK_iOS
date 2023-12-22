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
    //MARK: - property
    var modalartName: String = "" ///현재 보여지는 모다라트 타이틀
    var modalartList: [ModalartList] = [] ///모든 모다라트 리스트
    var nowShowModalArtNum: Int = 0 ///현재 보여지는 모다라트의 번호
    var nowShowModalArtIndex: Int = 0
    var mogakData: [DetailMogakData] = []
    let modalartNetwork = ModalartNetwork.shared ///API 통신
    let mogakNetwork = MogakDetailNetwork.shared
    
    var modalArtMainCellBgColor: String = "" ///현재 보여지는 모다라트 메인 셀의 배경색
    
    ///만다라트 이름 라벨
    private lazy var modalArtNameLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFont.semibold20L140.value
        label.textColor = DesignSystemColor.black.value
        return label
    }()
    
    ///모다라트들 리스트 보여주는 버튼
    private lazy var showModalArtListBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "downArrow"), for: .normal)
        btn.addTarget(self, action: #selector(showModalartListTapped), for: .touchUpInside)
        return btn
    }()
    
    ///...버튼
    private lazy var tacoBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "verticalEllipsisBlack"), for: .normal)
        btn.addTarget(self, action: #selector(tacoBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    ///모다라트 콜렉션 뷰
    private lazy var modalArtCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.backgroundColor = DesignSystemColor.signatureBag.value
        return collectionView
    }()
    
    //MARK: - 모다라트 전체 리스트 가져오기
    func getModalartAllList() {
        modalartNetwork.getModalartList { result in
            switch result {
            case .failure(let error):
                print(#fileID, #function, #line, "- error:\(error.localizedDescription)")
            case .success(let list):
                guard let modalartList = list else { return }
                self.modalartList = modalartList
                print(#fileID, #function, #line, "- modalartList checking:\(self.modalartList)")
                
                if modalartList.isEmpty {
                    self.modalartName = "내 모다라트"
                    self.modalArtMainCellBgColor = "BFC3D4"
                }
                else {
                    guard let firstData = modalartList.first else { return }
                    self.nowShowModalArtNum = firstData.id
                    self.nowShowModalArtIndex = 0
                    self.getModalartDetailInfo(id: self.nowShowModalArtNum)
                }
            }
        }
    }

    //MARK: - 단일 모다라트 디테일 정보 가져오기
    func getModalartDetailInfo(id: Int) {
        modalartNetwork.getDetailModalartInfo(modalartId: id) { result in
            switch result {
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            case .success(let modalInfo):
                guard let modalInfo = modalInfo else { return }

                self.nowShowModalArtNum = modalInfo.id
                self.modalartName = modalInfo.title
                self.modalArtNameLabel.text = modalInfo.title
                self.modalArtMainCellBgColor = modalInfo.color
                
                self.modalArtCollectionView.reloadData()
            }
        }
        getDetailMogakData(id: id)
    }
    
    func getDetailMogakData(id: Int) {
        modalartNetwork.getDetailMogakData(modalartId: id) { result in
            switch result {
            case .success(let data):
                self.mogakData = data?.result?.mogaks ?? []
                self.modalArtCollectionView.reloadData()
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            }
        }
    }

    //MARK: - 모다라트 생성 요청
    func createModalart() {
        let color = "BFC3D4"
        let modalartLast = self.modalartList.last ?? ModalartList(id: 0, title: "")
        
        let createdId = modalartLast.id + 1
        let createdTitle = "내 모다라트\(createdId)"

        let data = ModalartMainData(id: createdId, title: createdTitle, color: color)
        modalartNetwork.createDetailModalart(data: data) { result in
            switch result {
            case .success(let modalartMainData):
                print(#fileID, #function, #line, "- modalartMainData🌸: \(modalartMainData)")
                self.nowShowModalArtNum = modalartMainData.id
                self.modalartName = modalartMainData.title
                self.modalArtNameLabel.text = modalartMainData.title
                self.modalArtMainCellBgColor = modalartMainData.color
                self.mogakData = []
                self.modalartList.append(ModalartList(id: modalartMainData.id, title: modalartMainData.title))
                self.modalArtCollectionView.reloadData()
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - 모다라트 삭제 요청
    func deleteModalart() {
        modalartNetwork.deleteModalart(id: self.nowShowModalArtNum) { result in
            switch result {
            case .success(let responseResult):
                if responseResult {
                    self.getModalartAllList()
                }
            case .failure(let error):
                print(#fileID, #function, #line, "- error:\(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - 선택한 모각의 모든 조각들 가져오기
    func getMogakDetail(_ mogakData: DetailMogakData) {
        mogakNetwork.getAllMogakDetailJogaks(mogakId: mogakData.mogakId) { result in
            switch result {
            case .success(let jogakList):
                print(#fileID, #function, #line, "- jogakList: \(jogakList)")
                guard let jogakList = jogakList else { return }
                let mogakMainVC = MogakMainViewController()
                mogakMainVC.mogakList = self.mogakData
                mogakMainVC.selectedMogak = mogakData
                mogakMainVC.jogakList = jogakList
                mogakMainVC.modalartId = self.nowShowModalArtNum
                self.navigationController?.pushViewController(mogakMainVC, animated: true)
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            }
        }
    }
    
    func editModalart(_ changeTitle: String, _ changeColor: String) {
        let data = ModalartMainData(id: self.nowShowModalArtNum, title: changeTitle, color: changeColor)
        modalartNetwork.editModalart(data: data) { result in
            switch result {
            case .success(let modalartMainData):
                self.modalartName = modalartMainData.title
                self.modalArtMainCellBgColor = modalartMainData.color
                self.modalArtNameLabel.text = modalartMainData.title
                self.modalartList[self.nowShowModalArtIndex] = ModalartList(id: modalartMainData.id, title: modalartMainData.title)
                self.modalArtCollectionView.reloadData()
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = DesignSystemColor.signatureBag.value
        collectionViewSetting()
        configureLayout()
        getModalartAllList()
        modalartNameLabelTapGesture()
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - 모다라트 이름 눌렀을 때 리스트 볼 수 있도록
    func modalartNameLabelTapGesture() {
        let nameLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(showModalartListTapped))
        self.modalArtNameLabel.isUserInteractionEnabled = true
        self.modalArtNameLabel.addGestureRecognizer(nameLabelTapGesture)
    }
    
    //MARK: - 현재 생성된 모다라트 리스트 보여줌
    @objc private func showModalartListTapped() {
        print(#fileID, #function, #line, "- 모다라트 추가 버튼 탭")
        let showModalartListModalVC = ShowModalArtListModal()
        showModalartListModalVC.modalArtNameList = modalartList
        
        ///모다라트 리스트를 보여주는 모달에서 원하는 리스트를 선택했을 경우
        showModalartListModalVC.changeToSelectedModalart = { modalArtData, listIndex in
            let num = modalArtData.id
            let title = modalArtData.title
            
            ///모다라트 타이틀이 설정됬는지 체크
            let hasModalArtNameChecking: Bool = title.prefix(6) != "내 모다라트"
            ///모다라트 추가 리스트를 클릭했는지 체크
            let modalArtNameIsAddModalart: Bool = title == "모다라트 추가"
            
            self.nowShowModalArtNum = num
            self.nowShowModalArtIndex = listIndex
            ///모다라트 타이틀 설정됨
            if hasModalArtNameChecking && !modalArtNameIsAddModalart {
                self.getModalartDetailInfo(id: num)
            }
            ///모다라트 추가 클릭
            else if hasModalArtNameChecking && modalArtNameIsAddModalart {
                self.createModalart()
            }
            ///모다라트 타이틀 설정 안됨
            else {
                self.mogakData = []
                self.modalArtNameLabel.text = title
                self.modalartName = title
                self.modalArtCollectionView.reloadData()
            }
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
            self.createModalart()
        }
        
        ///모다라트 삭제하기
        let deleteModalArtAction = UIAlertAction(title: "현 모다라트 삭제", style: .destructive) { _ in
            //삭제하기 선택시 -> 정말 삭제하시겠습니까?라는 alert을 띄우기
            if self.modalartList.isEmpty {
                return
            } else {
                let bottomSheetVC = AskDeleteModal()
                if let sheet = bottomSheetVC.sheetPresentationController {
                    if #available(iOS 16.0, *) {
                        sheet.detents = [.custom() { context in
                            return 239
                        }]
                    } else {
                        sheet.detents = [.medium()]
                    }
                    sheet.prefersGrabberVisible = true
                }
                bottomSheetVC.startDelete = {
                    if self.modalartList.count == 1 { //현재 삭제하려고 하는 모다라트가 마지막 하나일 경우 -> 다시 하나 생성
                        self.createModalart()
                    } else {
                        self.deleteModalart()
                    }
                }
                self.present(bottomSheetVC, animated: true)
            }

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
        let modalArtWidthSize = screenWidthSize - 50 //모각 사이간격이 10, padding이 20
        
        //MARK: - 모다라트 이름 라벨 레이아웃
        modalArtNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
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
//            $0.width.equalTo(modalArtWidthSize)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(520)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}

extension ModalartMainViewController: UICollectionViewDelegate {
    //이걸 통해서 어떤 모각이 선택되었는지를 알 수 있음
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- 선택된 아이템: \(indexPath.row)")
        
        guard let cellType = collectionView.cellForItem(at: indexPath)?.reuseIdentifier else { return }
        if cellType == EmptyMogakCell.identifier {
            print(#fileID, #function, #line, "- 아무것도 없는 모각 셀")
            if String(modalartName.prefix(6)) == "내 모다라트" {
                let bottomSheetVC = NeedModalArtMainTitleModal()
                if let sheet = bottomSheetVC.sheetPresentationController {
                    if #available(iOS 16.0, *) {
                        sheet.detents = [.custom() { context in
                            return 200
                        }]
                    } else {
                        sheet.detents = [.medium()]
                    }
                    sheet.prefersGrabberVisible = true
                }
                self.present(bottomSheetVC, animated: true)
            } else {
                print(#fileID, #function, #line, "- 작은 모다라트 설정으로 이동")
            }
        }
        else if cellType == ModalartMainCell.identifier {
            let hasModalArtNameChecking: Bool = String(modalartName.prefix(6)) != "내 모다라트"
            let bottomSheetVC = SetModalartTitleModal()
            if let sheet = bottomSheetVC.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom() { context in
                        return 292
                    }]
                } else {
                    sheet.detents = [.medium()]
                }
                sheet.prefersGrabberVisible = true
            }

            bottomSheetVC.titleSetTextField.text = hasModalArtNameChecking ? modalartName : nil
            bottomSheetVC.isTitleSetUp = hasModalArtNameChecking ? true : false
            bottomSheetVC.titleBgColor = hasModalArtNameChecking ? modalArtMainCellBgColor : ""

            bottomSheetVC.changeMainMogak = { bgColor, modalartTitle in
                self.editModalart(modalartTitle, bgColor)
            }

            self.present(bottomSheetVC, animated: true)
        }
        else {
            let row = indexPath.row
            let selectedMogak = row <= 4 ? self.mogakData[row] : self.mogakData[row - 1]
            self.getMogakDetail(selectedMogak)
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
            let hasModalArtNameChecking: Bool = String(modalartName.prefix(6)) != "내 모다라트"
            mainMogakCell.mainBackgroundColor = hasModalArtNameChecking ? modalArtMainCellBgColor : "BFC3D4"
            print(#fileID, #function, #line, "- 내 모다라트 이름 확인:\(hasModalArtNameChecking)")
            mainMogakCell.mainLabelText = hasModalArtNameChecking ? modalartName : "큰 목표 \n추가"//
            mainMogakCell.cellDataSetting()
            return mainMogakCell
        } else { //그외에는 일반 셀
            return checkEmptyCell(row, mogakCell, emptyMogakCell)
        }
    }
    
    //MARK: - 중앙 셀을 기준으로 중앙 셀 앞에 있는 셀인지 뒤에 있는 셀인지 체크
    func checkEmptyCell(_ row: Int, _ mogakCell: MogakCell, _ emptyMogakCell: EmptyMogakCell) -> UICollectionViewCell {
        print(#fileID, #function, #line, "- mogakData.count⭐️: \(mogakData.count)")
        if (mogakData.count > row && row < 4) { //0, 1, 2, 3 row
            mogakCell.goalCategoryLabelText = mogakData[row].bigCategory.name
            mogakCell.goalContentLabelText = mogakData[row].title
//            mogakCell.goalCategoryLabelBackgoundColor = "009967"
            mogakCell.goalCategoryLabelTextColor = mogakData[row].color ?? "009967"
            mogakCell.cellDataSetting()
            return mogakCell
        } else if (mogakData.count > row - 1 && row > 4) { //5, 6, 7, 8 row
            mogakCell.goalCategoryLabelText = mogakData[row - 1].bigCategory.name
            mogakCell.goalContentLabelText = mogakData[row - 1].title
//            mogakCell.goalCategoryLabelBackgoundColor = "E8EBFE"
            mogakCell.goalCategoryLabelTextColor = mogakData[row - 1].color ?? "475FFD"
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
