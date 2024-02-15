//
//  MogakMainCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/06.
//

import Foundation
import UIKit
import SnapKit

class MogakMainViewController: UIViewController {
    //MARK: - properties
    var mogakList: [DetailMogakData] = []
    
    var selectedMogak: DetailMogakData = DetailMogakData(mogakId: 0, title: "", bigCategory: MainCategory(id: 0, name: ""), smallCategory: "", color: "")
    var jogakList: [JogakDetail] = []
    let mogakNetwork = MogakDetailNetwork.shared
    let modalartNetwork = ModalartNetwork.shared
    var modalartId: Int = 0
    /// - ...버튼
    private lazy var rightBtn: UIBarButtonItem = {
        let btn = UIBarButtonItem(image: UIImage(named: "verticalEllipsisBlack"), style: .plain, target: self, action: #selector(navigationRightBtnTapped))
        
        return btn
    }()
    
    /// - 모각 리스트 보여주는 콜렉션 뷰
    lazy var mogakListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = DesignSystemColor.signatureBag.value
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    /// 모각 만다라트
    private lazy var mogakMandalartCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.backgroundColor = DesignSystemColor.signatureBag.value
        return collectionView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationBarSetting()
    }
    
    override func viewDidLoad() {
        print(#fileID, #function, #line, "- jogakList: \(self.mogakList)")
        print(#fileID, #function, #line, "- selectedMogak: \(self.selectedMogak)")
        super.viewDidLoad()
        self.viewSetting()
        self.configureLayout()
        self.mogakListSetting()
        self.mogakMandalartSetting()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        if self.isMovingFromParent {
            if let vc = self.navigationController?.viewControllers.last as? ModalartMainViewController {
                vc.getDetailMogakData(id: self.modalartId)
            }
        }
    }
    
    func viewSetting() {
        self.view.backgroundColor = DesignSystemColor.signatureBag.value
    }
    
    func navigationBarSetting() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.rightBarButtonItem = self.rightBtn
        self.navigationItem.title = "세부목표"
    }
    
    func mogakListSetting() {
        self.mogakListCollectionView.register(MogakListCell.self, forCellWithReuseIdentifier: MogakListCell.identifier)
        
        mogakListCollectionView.dataSource = self
        mogakListCollectionView.delegate = self
    }
    
    func mogakMandalartSetting() {
        self.mogakMandalartCollectionView.register(EmptyJogakCell.self, forCellWithReuseIdentifier: EmptyJogakCell.identifier)
        
        self.mogakMandalartCollectionView.register(ModalartMainCell.self, forCellWithReuseIdentifier: ModalartMainCell.identifier)
        
        self.mogakMandalartCollectionView.register(JogakCell.self, forCellWithReuseIdentifier: JogakCell.identifier)
        
        self.mogakMandalartCollectionView.register(IsRoutineJogakCell.self, forCellWithReuseIdentifier: IsRoutineJogakCell.identifier)
        
        mogakMandalartCollectionView.delegate = self
        mogakMandalartCollectionView.dataSource = self
    }
    
    @objc private func navigationRightBtnTapped() {
        print(#fileID, #function, #line, "- 이클립스 버튼 체크")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteModalArtAction = UIAlertAction(title: "\(selectedMogak.title) 삭제", style: .destructive) { _ in
            //삭제하기 선택시 -> 정말 삭제하시겠습니까?라는 alert을 띄우기
            if self.mogakList.isEmpty {
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
                    self.deleteMogak()
                }
                self.present(bottomSheetVC, animated: true)
            }
        }
        
        ///액션sheet취소
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            print(#fileID, #function, #line, "- <#comment#>")
            self.dismiss(animated: false)
        }
        
        actionSheet.addAction(deleteModalArtAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
    
   
    
}

extension MogakMainViewController {
    private func configureLayout() {
        self.view.addSubviews(mogakListCollectionView, mogakMandalartCollectionView)
        
        mogakListCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        mogakMandalartCollectionView.snp.makeConstraints{
//            $0.width.equalTo(modalArtWidthSize)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(520)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}

//MARK: - API 통신
extension MogakMainViewController {
    //MARK: - 선택한 모각의 모든 조각들 가져오기
    func getMogakDetail(_ mogakData: DetailMogakData) {
        ///유저 액션 막기
        self.view.isUserInteractionEnabled = false
        let jogakDate = Date().jogakTodayDateToString()
        mogakNetwork.getAllMogakDetailJogaks(mogakId: mogakData.mogakId, date: jogakDate) { result in
            self.view.isUserInteractionEnabled = true
            switch result {
            case .success(let jogakList):
                print(#fileID, #function, #line, "- jogakList: \(jogakList)")
                guard let jogakList = jogakList else { return }
                self.jogakList = jogakList
                self.mogakMandalartCollectionView.reloadData()
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - 모각 삭제
    func deleteMogak() {
        self.view.isUserInteractionEnabled = false
        mogakNetwork.deleteMogak(mogakId: selectedMogak.mogakId) { result in
            self.view.isUserInteractionEnabled = true
            switch result {
            case .success(let responseResult):
                if responseResult {
                    self.getDetailMogakData()
                }
            case .failure(let err):
                print(#fileID, #function, #line, "- error: \(err)")
            }
        }
    }
    
    //MARK: - 모각데이터 가져오기
    func getDetailMogakData() {
        self.view.isUserInteractionEnabled = false
        modalartNetwork.getDetailMogakData(modalartId: self.modalartId) { result in
            self.view.isUserInteractionEnabled = true
            switch result {
            case .success(let data):
                self.mogakList = data?.result?.mogaks ?? []
                if let selectedMogak = self.mogakList.first {
                    self.selectedMogak = selectedMogak
                    self.mogakListCollectionView.reloadData()
                    self.getMogakDetail(selectedMogak)
                } else {
                    //여기 alert만들기
                    let modalAlertAction = UIAlertAction(title: "확인", style: .default) { _ in
                        self.navigationController?.popViewController(animated: false)
                    }
                    let modalAlert = UIAlertController(title: "마지막 모각을 삭제하셨습니다", message: "메인 모다라트 화면으로 이동합니다.", preferredStyle: .alert)
                    
                    modalAlert.addAction(modalAlertAction)
                    self.present(modalAlert, animated: true)
                }
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - 조각 삭제
    func deleteJogak(_ jogakId: Int) {
        self.view.isUserInteractionEnabled = false
        mogakNetwork.deleteJogak(jogakId: jogakId) { result in
            self.view.isUserInteractionEnabled = true
            switch result {
            case .success(_):
                self.getMogakDetail(self.selectedMogak)
            case .failure(let failure):
                print(#fileID, #function, #line, "- error: \(failure)")
            }
        }
    }
}


extension MogakMainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.mogakListCollectionView {
            return mogakList.count
        }
        else if collectionView == self.mogakMandalartCollectionView {
            return 9
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        if collectionView == self.mogakListCollectionView {
            guard let cell = mogakListCollectionView.dequeueReusableCell(withReuseIdentifier: MogakListCell.identifier, for: indexPath) as? MogakListCell else { return UICollectionViewCell() }
            
            print(#fileID, #function, #line, "- mogakList: \(mogakList)")
            cell.titleLabel.text = mogakList[row].bigCategory.name
            cell.titleLabel.tag = mogakList[row].mogakId
//            guard let selectedMogakTitle = selectedMogak.title else { return UICollectionViewCell() }
            print(#fileID, #function, #line, "- cell.tag: \(cell.titleLabel.tag)")
            print(#fileID, #function, #line, "- cell.tag: \(selectedMogak.bigCategory.id)")
            if cell.titleLabel.tag == selectedMogak.mogakId {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            }
            return cell
        }
        
        else if collectionView == self.mogakMandalartCollectionView {
            guard let emptyJogakCell = mogakMandalartCollectionView.dequeueReusableCell(withReuseIdentifier: EmptyJogakCell.identifier, for: indexPath) as? EmptyJogakCell else { return UICollectionViewCell() }
            
            guard let mainJogakCell = mogakMandalartCollectionView.dequeueReusableCell(withReuseIdentifier: ModalartMainCell.identifier, for: indexPath) as? ModalartMainCell else { return UICollectionViewCell() }
            
            guard let jogakCell = mogakMandalartCollectionView.dequeueReusableCell(withReuseIdentifier: JogakCell.identifier, for: indexPath) as? JogakCell else { return UICollectionViewCell() }
            
            guard let isRoutineJogakCell = mogakMandalartCollectionView.dequeueReusableCell(withReuseIdentifier: IsRoutineJogakCell.identifier, for: indexPath) as? IsRoutineJogakCell else { return UICollectionViewCell() }
            
            if row == 4 {
                mainJogakCell.mainLabelText = selectedMogak.title
                mainJogakCell.mainBackgroundColor = selectedMogak.color ?? "475FFD"
                mainJogakCell.cellDataSetting()
                return mainJogakCell
            } else {
                return checkEmptyCell(row, jogakCell, emptyJogakCell, isRoutineJogakCell)
            }
            
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.mogakMandalartCollectionView {
            guard let cellType = collectionView.cellForItem(at: indexPath)?.reuseIdentifier else { return }
            if cellType != EmptyJogakCell.identifier {
                let row = indexPath.row
                let bottomSheetVC = JogakSimpleModalViewController()
                bottomSheetVC.mogakCategory = self.selectedMogak.bigCategory.name
                let jogakData = row <= 4 ? jogakList[row] : jogakList[row - 1]
                bottomSheetVC.jogakData = jogakData
                
                if let sheet = bottomSheetVC.sheetPresentationController {
                    if #available(iOS 16, *) {
                        sheet.detents = [.custom() { context in
                            let bottomHeight = jogakData.isRoutine ? 238 : 200
                            return CGFloat(bottomHeight)
                        }]
                    } else {
                        sheet.detents = [.medium()]
                    }
                    sheet.prefersGrabberVisible = true
                }
                bottomSheetVC.startDeleteJogak = {
                    self.deleteJogak(jogakData.jogakID)
                }
                self.present(bottomSheetVC, animated: true)
            }
            
        } else if collectionView == self.mogakListCollectionView {
            let row = indexPath.row
            self.selectedMogak = self.mogakList[row]
            self.getMogakDetail(selectedMogak)
        }
    }
    
    func checkEmptyCell(_ row: Int, _ jogakCell: JogakCell, _ emptyJogakCell: EmptyJogakCell, _ isRoutineJogakCell: IsRoutineJogakCell) -> UICollectionViewCell {
        print(#fileID, #function, #line, "- mogakData.count⭐️: \(jogakList.count)")
        if (jogakList.count > row && row < 4) { //0, 1, 2, 3 row
            print(#fileID, #function, #line, "- jogakList[row]: \(jogakList[row])")
            if jogakList[row].isRoutine {
                guard let days = jogakList[row].days else { return UICollectionViewCell() }
                
                if !days.isEmpty {
                    isRoutineJogakCell.goalRepeatDayLabelText = days.joined(separator: ",")
                } else {
                    isRoutineJogakCell.goalRepeatDayLabelText = "0회"
                }
                
                isRoutineJogakCell.goalContentLabelText = jogakList[row].title
                isRoutineJogakCell.goalCategoryLabelTextColor = selectedMogak.color ?? "475FFD"
                isRoutineJogakCell.cellDataSetting()
                return isRoutineJogakCell
            } else {
                if let days = jogakList[row].days {
                    jogakCell.goalRepeatDayLabelText = days.joined(separator: ",")
                } else {
                    jogakCell.goalRepeatDayLabelText = "0회"
                }
                
                jogakCell.goalContentLabelText = jogakList[row].title
                jogakCell.goalCategoryLabelTextColor = selectedMogak.color ?? "475FFD"
                jogakCell.cellDataSetting()
            
                return jogakCell
            }
            
        } else if (jogakList.count > row - 1 && row > 4) { //5, 6, 7, 8 row
            if jogakList[row - 1].isRoutine {
                if let days = jogakList[row - 1].days {
                    isRoutineJogakCell.goalRepeatDayLabelText = days.joined(separator: ",")
                } else {
                    isRoutineJogakCell.goalRepeatDayLabelText = "0회"
                }
                
                isRoutineJogakCell.goalContentLabelText = jogakList[row - 1].title
                isRoutineJogakCell.goalCategoryLabelTextColor = selectedMogak.color ?? "475FFD"
                isRoutineJogakCell.cellDataSetting()
                return isRoutineJogakCell
            } else {
                if let days = jogakList[row - 1].days {
                    jogakCell.goalRepeatDayLabelText = days.joined(separator: ",")
                } else {
                    jogakCell.goalRepeatDayLabelText = "0회"
                }
                
                jogakCell.goalContentLabelText = jogakList[row - 1].title
                jogakCell.goalCategoryLabelTextColor = selectedMogak.color ?? "475FFD"
                jogakCell.cellDataSetting()
    //            jogakCell.configureLayoutDayLabel()
                return jogakCell
            }
            
        } else {
            return emptyJogakCell
        }
    }
    
    
}

extension MogakMainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.mogakListCollectionView {
            guard let cell = mogakListCollectionView.dequeueReusableCell(withReuseIdentifier: MogakListCell.identifier, for: indexPath) as? MogakListCell else {
                return .zero
            }
            cell.titleLabel.text = mogakList[indexPath.row].bigCategory.name
            // ✅ sizeToFit() : 텍스트에 맞게 사이즈가 조절
            cell.titleLabel.sizeToFit()
            
            // ✅ cellWidth = 글자수에 맞는 UILabel 의 width + 20(여백)
            let cellWidth = cell.titleLabel.frame.width + 30
            
            return CGSize(width: cellWidth, height: 30)
        } else {
            let cellWidth: CGFloat = self.mogakMandalartCollectionView.frame.width / 3.0 - 10 //하나의 셀이 가지는 넓이의최소 크기
            let cellHeight: CGFloat = self.mogakMandalartCollectionView.frame.height / 3.0 - 10//하나의 셀이 가지는 높이의 최소 크기
            return CGSizeMake(cellWidth, cellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    //
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    //
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}


