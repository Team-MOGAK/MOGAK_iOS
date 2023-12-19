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
    var mogakList: [MogakCategory] = []
    var selectedMogak: MogakCategory = MogakCategory(title: "", bigCategory: BigCategory(id: 0, name: ""), smallCategory: "", color: "")
    
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
        super.viewDidLoad()
        self.viewSetting()
        self.configureLayout()
        self.mogakListSetting()
        self.mogakMandalartSetting()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
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
        
        mogakMandalartCollectionView.delegate = self
        mogakMandalartCollectionView.dataSource = self
        
    }
    
    @objc private func navigationRightBtnTapped() {
        print(#fileID, #function, #line, "- 이클립스 버튼 체크")
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
            cell.titleLabel.text = mogakList[row].title
//            guard let selectedMogakTitle = selectedMogak.title else { return UICollectionViewCell() }
            
            if cell.titleLabel.text == selectedMogak.title {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
                collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
            return cell
        }
        
        else if collectionView == self.mogakMandalartCollectionView {
            guard let emptyJogakCell = mogakMandalartCollectionView.dequeueReusableCell(withReuseIdentifier: EmptyJogakCell.identifier, for: indexPath) as? EmptyJogakCell else { return UICollectionViewCell() }
            
            guard let mainJogakCell = mogakMandalartCollectionView.dequeueReusableCell(withReuseIdentifier: ModalartMainCell.identifier, for: indexPath) as? ModalartMainCell else { return UICollectionViewCell() }
            
            if row == 4 {
                mainJogakCell.mainLabelText = selectedMogak.title
                mainJogakCell.mainBackgroundColor = "475FFD"
                mainJogakCell.cellDataSetting()
                return mainJogakCell
            } else {
                return emptyJogakCell
            }
            
        }
        return UICollectionViewCell()
    }
}

extension MogakMainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.mogakListCollectionView {
            guard let cell = mogakListCollectionView.dequeueReusableCell(withReuseIdentifier: MogakListCell.identifier, for: indexPath) as? MogakListCell else {
                return .zero
            }
            cell.titleLabel.text = mogakList[indexPath.row].title
            // ✅ sizeToFit() : 텍스트에 맞게 사이즈가 조절
            cell.titleLabel.sizeToFit()
            
            // ✅ cellWidth = 글자수에 맞는 UILabel 의 width + 20(여백)
            let cellWidth = cell.titleLabel.frame.width + 20
            
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


