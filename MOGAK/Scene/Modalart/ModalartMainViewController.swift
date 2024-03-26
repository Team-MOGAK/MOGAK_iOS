//
//  ModalartMainViewController.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/04.
//

import Foundation
import UIKit
import SnapKit
import Lottie

protocol MogakSettingButtonTappedDelegate: AnyObject {
    func cellButtonTapped(mogakData: DetailMogakData)
}

protocol MogakCreatedReloadDelegate: AnyObject {
    func reloadModalart()
}

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
    //var mogakCellData: DetailMogakData = DetailMogakData(mogakId: 0, title: "", state: "", bigCategory: MainCategory(id: 0, name: ""), smallCategory: "", color: "", startAt: "", endAt: "")
    var mogakCellData: DetailMogakData = DetailMogakData(mogakId: 0, title: "", bigCategory: MainCategory(id: 0, name: ""), smallCategory: "", color: "")
    
    ///현재 보여지는 모다라트 메인 셀의 배경색
    var modalArtMainCellBgColor: String = ""
    
    lazy var loadingView: LottieAnimationView = {
        let view = LottieAnimationView(name: "loading")
        view.backgroundColor = .gray
        view.layer.cornerRadius = 10
        view.loopMode = .loop
        view.center = self.view.center
        view.isHidden = true
        return view
    }()
    
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
    lazy var modalArtCollectionView: UICollectionView = {
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
        getModalartAllList()
        modalartNameLabelTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
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
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        ///모다라트 추가하기
        let addModalArtAction = UIAlertAction(title: "모다라트 추가", style: .default) { _ in
            self.createModalart()
        }
        
        ///모다라트 삭제하기
        let deleteModalArtAction = UIAlertAction(title: "현 모다라트 삭제", style: .destructive) { _ in
            //삭제하기 선택시 -> 정말 삭제하시겠습니까?라는 alert을 띄우기
            if self.modalartList.isEmpty {
                let readyAlertAction = UIAlertAction(title: "확인", style: .default)
                let readyAlert = UIAlertController(title: "모다라트 삭제 오류", message: "현재 생성된 모다라트가 없어서 \n삭제할 수 없습니다.", preferredStyle: .alert)
                readyAlert.addAction(readyAlertAction)
                self.present(readyAlert, animated: true)
                
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
                    self.deleteModalart()
//                    if self.modalartList.count == 1 { //현재 삭제하려고 하는 모다라트가 마지막 하나일 경우 -> 다시 하나 생성
//
//                        self.createModalart()
//                    } else {
//                        self.deleteModalart()
//                    }
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

//MARK: - API 통신
extension ModalartMainViewController {
    //MARK: - 모다라트 전체 리스트 가져오기
    func getModalartAllList() {
        LoadingIndicator.showLoading()
        modalartNetwork.getModalartList { result in
            switch result {
            case .failure(let error):
                print(#fileID, #function, #line, "- error:\(error.localizedDescription)")
                LoadingIndicator.hideLoading()
            case .success(let list):
                guard let modalartList = list else { return }
                self.modalartList = modalartList
                if self.modalartList.isEmpty {
                    self.createModalart()
                }
                else {
                    guard let firstData = modalartList.first else { return }
                    self.nowShowModalArtNum = firstData.id
                    self.nowShowModalArtIndex = 0
                    self.getModalartDetailInfo(id: self.nowShowModalArtNum)
                }
                LoadingIndicator.hideLoading()
            }
        }
    }

    //MARK: - 단일 모다라트 디테일 정보 가져오기
    func getModalartDetailInfo(id: Int) {
//        self.loadingViewPlay()
        LoadingIndicator.showLoading()
        modalartNetwork.getDetailModalartInfo(modalartId: id) { result in

            switch result {
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
//                self.loadingViewStop()
                LoadingIndicator.hideLoading()
            case .success(let modalInfo):
                guard let modalInfo = modalInfo else { return }

                self.nowShowModalArtNum = modalInfo.id
                self.modalartName = modalInfo.title
                self.modalArtNameLabel.text = modalInfo.title
                self.modalArtMainCellBgColor = modalInfo.color
                
                self.modalArtCollectionView.reloadData()
//                self.loadingViewStop()
                LoadingIndicator.hideLoading()
            }
        }
        getDetailMogakData(id: id)
    }
    
    func getDetailMogakData(id: Int) {
//        self.loadingViewPlay()
        LoadingIndicator.showLoading()
        modalartNetwork.getDetailMogakData(modalartId: id) { result in
            switch result {
            case .success(let data):
                self.mogakData = data?.result?.mogaks ?? []
                self.modalArtCollectionView.reloadData()
//                self.loadingViewStop()
                LoadingIndicator.hideLoading()
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
//                self.loadingViewStop()
                LoadingIndicator.hideLoading()
            }
        }
    }

    //MARK: - 모다라트 생성 요청
    func createModalart() {
        LoadingIndicator.showLoading()
        let color = "BFC3D4"
        let modalartLast = self.modalartList.last ?? ModalartList(id: 0, title: "")
        
        let createdId = modalartLast.id + 1
        let createdTitle = "내 모다라트\(createdId)"

        let data = ModalartMainData(id: createdId, title: createdTitle, color: color)
        modalartNetwork.createDetailModalart(data: data) { result in
//            self.view.isUserInteractionEnabled = true
            switch result {
            case .success(let modalartMainData):
                self.nowShowModalArtNum = modalartMainData.id
                self.modalartName = modalartMainData.title
                self.modalArtNameLabel.text = modalartMainData.title
                self.modalArtMainCellBgColor = modalartMainData.color
                self.mogakData = []
                self.modalartList.append(ModalartList(id: modalartMainData.id, title: modalartMainData.title))
                self.modalArtCollectionView.reloadData()
                LoadingIndicator.hideLoading()
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                LoadingIndicator.hideLoading()
            }
        }
    }
    
    //MARK: - 모다라트 삭제 요청
    func deleteModalart() {
        LoadingIndicator.showLoading()
        modalartNetwork.deleteModalart(id: self.nowShowModalArtNum) { result in
            switch result {
            case .success(let responseResult):
                if responseResult {
                    self.getModalartAllList()
                    LoadingIndicator.hideLoading()
                }
            case .failure(let error):
                print(#fileID, #function, #line, "- error:\(error.localizedDescription)")
                LoadingIndicator.hideLoading()
            }
        }
    }
    
    //MARK: - 선택한 모각의 모든 조각들 가져오기
    func getMogakDetail(_ mogakData: DetailMogakData) {
        LoadingIndicator.showLoading()
        let jogakDate = Date().jogakTodayDateToString()
        mogakNetwork.getAllMogakDetailJogaks(mogakId: mogakData.mogakId, date: jogakDate) { result in
            switch result {
            case .success(let jogakList):
                guard let jogakList = jogakList else { return }
                let mogakMainVC = MogakMainViewController()
                mogakMainVC.mogakList = self.mogakData
                mogakMainVC.selectedMogak = mogakData
                mogakMainVC.jogakList = jogakList
                mogakMainVC.modalartId = self.nowShowModalArtNum
                LoadingIndicator.hideLoading()
                self.navigationController?.pushViewController(mogakMainVC, animated: true)
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                LoadingIndicator.hideLoading()
            }
        }
    }
    
    //MARK: - 모다라트 수정
    func editModalart(_ changeTitle: String, _ changeColor: String) {
        LoadingIndicator.showLoading()
        let data = ModalartMainData(id: self.nowShowModalArtNum, title: changeTitle, color: changeColor)
        modalartNetwork.editModalart(data: data) { result in
            switch result {
            case .success(let modalartMainData):
                self.modalartName = modalartMainData.title
                self.modalArtMainCellBgColor = modalartMainData.color
                self.modalArtNameLabel.text = modalartMainData.title
                self.modalartList[self.nowShowModalArtIndex] = ModalartList(id: modalartMainData.id, title: modalartMainData.title)
                self.modalArtCollectionView.reloadData()
                LoadingIndicator.hideLoading()
                
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                LoadingIndicator.hideLoading()
            }
        }
    }
    
    func loadingViewPlay() {
        self.view.backgroundColor = .white
        self.view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        loadingView.play()
    }
    
    func loadingViewStop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.loadingView.stop()
            self.view.isUserInteractionEnabled = true
            self.loadingView.isHidden = true
        }
        
    }
}

//MARK: - 모다라트VC 뷰들 레이아웃 잡기
extension ModalartMainViewController {
    func configureLayout() {
        self.view.addSubviews(modalArtNameLabel, showModalArtListBtn, tacoBtn, modalArtCollectionView, loadingView)
        
        //모다라트 사이즈 설정
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let screenWidthSize = window.screen.bounds.width
        let modalArtWidthSize = screenWidthSize - 50 //모각 사이간격이 10, padding이 20
        
        loadingView.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(200)
//            make.size.equalTo(300)
            make.center.equalToSuperview()
        }
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
                let mogakInitVC = MogakInitViewController()
                mogakInitVC.currentModalartId = nowShowModalArtNum
                print("모다라트 아이디 : \(mogakInitVC.currentModalartId)")
                
                mogakInitVC.delegate = self
                self.navigationController?.pushViewController(mogakInitVC, animated: true)
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
        
        mogakCell.delegate = self
        
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
                mogakCell.mogakCellData = mogakData[row]
                mogakCell.cellDataSetting()
                return mogakCell
            } else if (mogakData.count > row - 1 && row > 4) { //5, 6, 7, 8 row
                mogakCell.mogakCellData = mogakData[row - 1]
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

extension ModalartMainViewController: MogakSettingButtonTappedDelegate {
    func cellButtonTapped(mogakData: DetailMogakData) {
        print(#fileID, #function, #line, "- mogakDetailData 넘겨받기: \(mogakData)")
        let mogakEditVC = MogakEditViewController()
        // 타이틀 넘기기
        mogakEditVC.mogakTextField.text = mogakData.title
        
        // 카테고리 넘기기
        let category = mogakData.bigCategory.name
        let categoryList = mogakEditVC.categoryList
        let categoryIndex = categoryList.firstIndex(of: category)!
        print("categoryIndex: \(categoryIndex)")
        
        mogakEditVC.currentMogakId = mogakData.mogakId
        mogakEditVC.currentBigCategory = mogakData.bigCategory.name
        mogakEditVC.currentColor = String(mogakData.color!.suffix(6))
        //mogakEditVC.categoryCollectionView.selectItem(at: [0, categoryIndex], animated: false, scrollPosition: .init())
        
        // 컬러 넘기기
        let color = mogakData.color
        print(color!)
        let colorPalette = mogakEditVC.titleColorPalette
//        let colorIndex = colorPalette.firstIndex(of: color!)!
//        print(#fileID, #function, #line, "- mogakData Color: \(String(describing: mogakData.color))")
//        mogakEditVC.colorCollectionView.selectItem(at: [0, colorIndex], animated: false, scrollPosition: .init())
        if let colorIndex = colorPalette.firstIndex(of: String(color!.suffix(6))) {
            print("#########3")
        }
        mogakEditVC.delegate = self
        self.navigationController?.pushViewController(mogakEditVC, animated: true)
    }
}

extension ModalartMainViewController: MogakCreatedReloadDelegate {
    func reloadModalart() {
        print("reload Modalart: DELEGATE 과연???")
        self.getModalartDetailInfo(id: nowShowModalArtNum)
        modalArtCollectionView.reloadData()
    }
}
