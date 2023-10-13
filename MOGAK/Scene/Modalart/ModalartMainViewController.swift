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
    var modalArtName: String = "내 모다라트"
    
    private lazy var modalArtNameLabel: UILabel = {
        let label = UILabel()
        label.text = modalArtName //데이터 받아오면 그 모다라트 이름으로 변경 필요
        label.font = DesignSystemFont.semibold20L140.value
        label.textColor = DesignSystemColor.black.value
        return label
    }()
    
    private lazy var showModalArtListBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "downArrow"), for: .normal)
        btn.addTarget(self, action: #selector(showModalArtListBtnTapped), for: .touchUpInside)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = DesignSystemColor.signatureBag.value
        
        collectionViewSetting()
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - 모다라트 리스트 보기(custom sheet)
    @objc private func showModalArtListBtnTapped() {
        print(#fileID, #function, #line, "- 모다라트 리스트 보기 버튼 탭⭐️")
    }
    
    //MARK: - 타코버튼 탭(모다라트 추가, 삭제하기 actionSheet)
    @objc private func tacoBtnTapped() {
        print(#fileID, #function, #line, "- 모다라트 추가 삭제버튼(타코버튼) 탭 ⭐️")
    }
    
    func collectionViewSetting() {
        //cell등록
        modalArtCollectionView.register(EmptyMogakCell.self, forCellWithReuseIdentifier: EmptyMogakCell.identifier)
        modalArtCollectionView.register(MogakCell.self, forCellWithReuseIdentifier: MogakCell.identifier)
        modalArtCollectionView.register(ModalartMainCell.self, forCellWithReuseIdentifier: ModalartMainCell.identifier)
        
        //delegate, datasource를 사용할 viewcontroller설정
        modalArtCollectionView.delegate = self
        modalArtCollectionView.dataSource = self
//        modalArtCollectionView.reloadData()
    }

}

//MARK: - 모다라트VC 뷰들 레이아웃 잡기
extension ModalartMainViewController {
    func configureLayout() {
        self.view.addSubviews(modalArtNameLabel, showModalArtListBtn, tacoBtn, modalArtCollectionView)
        
        //MARK: - 모다라트 이름 라벨 레이아웃
        modalArtNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(60)
        }
        
        //MARK: - 사용자가 만들어놓은 모다라트 리스트 보기
        showModalArtListBtn.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.leading.equalTo(modalArtNameLabel.snp.trailing).offset(12)
            $0.top.equalTo(modalArtNameLabel.snp.top)
        }
        
        //MARK: - 타코버튼(모다라트 추가, 삭제하기 actionSheet)
        tacoBtn.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.top.equalToSuperview().offset(57)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        modalArtCollectionView.snp.makeConstraints{
            print(#fileID, #function, #line, "- ???⭐️")
//            $0.leading.equalTo(modalArtNameLabel.snp.leading)
            $0.width.equalTo(350)
            $0.height.equalTo(520)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(modalArtNameLabel.snp.top).offset(39)
        }
    }
}

//extension ModalartMainViewController: UICollectionViewDelegate {
//    func collecscroll
//}

extension ModalartMainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //한 섹션에 몇개의 아이템이 들어갈지
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(#fileID, #function, #line, "- 셀만들기⭐️")
        let mogakCategory: [(String, String)] = [("운동", "10키로 감량"), ("자기계발", "인생은 아름다워 읽기")]
        
        guard let emptyMogakCell = modalArtCollectionView.dequeueReusableCell(withReuseIdentifier: EmptyMogakCell.identifier, for: indexPath) as? EmptyMogakCell else { return UICollectionViewCell() }
        
        guard let mainMogakCell = modalArtCollectionView.dequeueReusableCell(withReuseIdentifier: ModalartMainCell.identifier, for: indexPath) as? ModalartMainCell else { return UICollectionViewCell() }
        
        guard let mogakCell = modalArtCollectionView.dequeueReusableCell(withReuseIdentifier: MogakCell.identifier, for: indexPath) as? MogakCell else { return UICollectionViewCell() }
        
        let row = indexPath.row
        
        if(row == 4) {
            mainMogakCell.mainBackgroundColor = "475FFD"
            mainMogakCell.mainLabelText = "운동하기"
            mainMogakCell.cellDataSetting()
            return mainMogakCell
        } else {
            return checkEmptyCell(row, mogakCell, emptyMogakCell)
        }
        
//        return emptyMogakCell
    }
    
    func checkEmptyCell(_ row: Int, _ mogakCell: MogakCell, _ emptyMogakCell: EmptyMogakCell) -> UICollectionViewCell {
//        let mogakCategory: [(String, String)] = [("운동", "10키로 감량"), ("자기계발", "인생은 아름다워 읽기"),("운동", "10키로 감량")]
        let mogakCategory: [(String, String)] = []
        if (mogakCategory.count > row && row < 4) {
            mogakCell.goalCategoryLabelText = mogakCategory[row].0
            mogakCell.goalContentLabelText = mogakCategory[row].1
            mogakCell.goalCategoryLabelBackgoundColor = "E8EBFE"
            mogakCell.goalCategoryLabelTextColor = "475FFD"
            mogakCell.cellDataSetting()
            return mogakCell
        } else if (mogakCategory.count > row - 1 && row > 4) {
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
