//
//  MogakInitViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/23.
//

import UIKit
import SnapKit
import Then
import ReusableKit

class MogakInitViewController: UIViewController {
    
    private var categorySelectedList : [String] = []
    private var repeatSelectedList : [String] = []
    private var collectionViewHeightConstraint: NSLayoutConstraint!
    
    enum Reusable {
        static let categoryCell = ReusableCell<CategoryCell>()
        static let repeatCell = ReusableCell<RepeatCell>()
    }
    
    
    // MARK: - 모각 이름
    private let mogakLabel : UILabel = {
        let label = UILabel()
        label.text = "모각 이름"
        label.font = UIFont.pretendard(.semiBold, size: 14)
        return label
    }()
    
    private let mogakTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "조각 이름을 적어주세요"
        textField.font = UIFont.pretendard(.medium, size: 16)
        textField.borderStyle = .none
        //        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        textField.leftViewMode = .unlessEditing
        return textField
    }()
    
    private let mogakUnderLineView : UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    // MARK: - 카테고리
    private let categoryLabel : UILabel = {
        let label = UILabel()
        label.text = "카테고리"
        label.font = UIFont.pretendard(.semiBold, size: 14)
        label.textColor = UIColor(hex: "24252E")
        return label
    }()
    
    private let categoryList: [String] = [
        "자격증", "대외활동", "운동", "인사이트",
        "공모전", "직무공부", "산업분석", "어학",
        "강연/강의", "프로젝트", "스터디", "기타"
    ]
    
    private let categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 6
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        $0.isScrollEnabled = false
        $0.collectionViewLayout = layout
        $0.backgroundColor = .white
        $0.register(Reusable.categoryCell)
    }
    
    // MARK: - 반복 주기
    private let repeatLabel = UILabel().then {
        $0.text = "반복 주기"
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private lazy var toggleButton = UISwitch().then {
        $0.isOn = false
        $0.addTarget(self, action: #selector(toggleSwitchChanged(_:)), for: .valueChanged)
    }
    
    private let repeatList: [String] = [
        "월", "화", "수", "목","금",
        "토", "일"
    ]
    
    private let repeatCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 8 // 상하간격
        layout.minimumInteritemSpacing = 8 // 좌우간격
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        $0.isScrollEnabled = false
        $0.collectionViewLayout = layout
        $0.backgroundColor = .white
        $0.register(Reusable.repeatCell)
    }
    
    // MARK: - 날짜선택

    private let choiceDateLabel = UILabel().then {
        $0.text = "날짜 선택"
        $0.textColor = UIColor(hex: "24252E")
        $0.font = UIFont.pretendard(.semiBold, size: 14)
    }
    
    private let startLabel = UILabel().then {
        $0.text = "시작"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.medium, size: 16)
    }
    
    private let startTextField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        textField.leftViewMode = .unlessEditing
        textField.font = UIFont.pretendard(.medium, size: 16)
        textField.textColor = UIColor(hex: "475FFD")
        textField.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        textField.attributedPlaceholder = NSAttributedString(string: "yyyy/mm/dd(요일)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "BFC3D4"), .font: UIFont.pretendard(.medium, size: 16)])
        return textField
    }()
    
    private let endLabel = UILabel().then {
        $0.text = "종료"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.medium, size: 16)
    }
    
    private let endTextField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        textField.leftViewMode = .unlessEditing
        textField.font = UIFont.pretendard(.medium, size: 16)
        textField.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        textField.placeholder = "yyyy/mm/dd(요일)"
        textField.attributedPlaceholder = NSAttributedString(string: "yyyy/mm/dd(요일)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "BFC3D4"), .font: UIFont.pretendard(.medium, size: 16)])
        return textField
    }()
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.configureNavBar()
        self.configureMogakTop()
        self.configureCategory()
        self.configureRepeat()
        self.configureDate()
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.title = "모각 생성"
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.pretendard(.semiBold, size: 18)]
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "chevron.left")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "24252E")
    }
    
    private func configureMogakTop() {
        [mogakLabel, mogakTextField, mogakUnderLineView].forEach({view.addSubview($0)})
        self.mogakTextField.delegate = self
        
        mogakLabel.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(20)
        })
        
        mogakTextField.snp.makeConstraints({
            $0.top.equalTo(self.mogakLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        
        mogakUnderLineView.snp.makeConstraints({
            $0.top.equalTo(self.mogakTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(2)
        })
    }
    
    private func configureCategory() {
        [categoryLabel, categoryCollectionView].forEach({view.addSubview($0)})
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = self
        self.categoryCollectionView.tag = 1
        
        categoryLabel.snp.makeConstraints({
            $0.top.equalTo(self.mogakUnderLineView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        })
        
        categoryCollectionView.snp.makeConstraints({
            $0.top.equalTo(self.categoryLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(110)
        })
    }
    
    private func configureRepeat() {
        [repeatLabel, toggleButton, repeatCollectionView].forEach({view.addSubview($0)})
        self.repeatCollectionView.delegate = self
        self.repeatCollectionView.dataSource = self
        self.repeatCollectionView.tag = 2
        
        repeatCollectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewHeightConstraint = repeatCollectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightConstraint.isActive = true
        
        repeatLabel.snp.makeConstraints({
            $0.top.equalTo(self.categoryCollectionView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        })
        
        toggleButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalTo(self.repeatLabel.snp.centerY)
            $0.width.equalTo(60)
            $0.height.equalTo(26)
        })
        
        repeatCollectionView.snp.makeConstraints({
            $0.top.equalTo(self.repeatLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-99)
            $0.height.equalTo(110)
        })
    }
    
    private func configureDate() {
        [choiceDateLabel, startLabel, endLabel, startTextField, endTextField].forEach({view.addSubview($0)})
        
        choiceDateLabel.snp.makeConstraints({
            $0.top.equalTo(self.repeatCollectionView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        })
        
        startLabel.snp.makeConstraints({
            $0.top.equalTo(self.choiceDateLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(20)
        })
        
        startTextField.snp.makeConstraints({
            $0.centerY.equalTo(self.startLabel.snp.centerY)
            $0.leading.equalTo(self.startLabel.snp.trailing).offset(19)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
        })
        
        endLabel.snp.makeConstraints({
            $0.top.equalTo(self.startLabel.snp.bottom).offset(52)
            $0.leading.equalToSuperview().offset(20)
        })
        
        endTextField.snp.makeConstraints({
            $0.centerY.equalTo(self.endLabel.snp.centerY)
            $0.leading.equalTo(self.endLabel.snp.trailing).offset(19)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
        })
    }
    
    // MARK: - objc
    
    @objc private func toggleSwitchChanged(_ sender: UISwitch) {
        // 토글 스위치의 상태에 따라 collectionView의 상태를 변경
        repeatCollectionView.isHidden = !sender.isOn
        
        // 변경된 상태에 따라 collectionView의 높이 애니메이션과 함께 조절
        UIView.animate(withDuration: 0.3) {
            self.collectionViewHeightConstraint.constant = sender.isOn ? 110 : 0 // 원하는 높이로 조절
            self.view.layoutIfNeeded()
        }
        
        
    }
}

// MARK: - 익스텐션

extension MogakInitViewController: UITextFieldDelegate {
    //외부 탭시 키보드 내림.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    // 리턴 키 입력 시 키보드 내림
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension MogakInitViewController: UICollectionViewDataSource {
    // cell갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return categoryList.count
        } else if collectionView.tag == 2 {
            return repeatList.count
        }
        //        return categoryList.count
        return 3
    }
    
    // cell 선언
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {
            let cell = collectionView.dequeue(Reusable.categoryCell, for: indexPath)
            cell.textLabel.text = categoryList[indexPath.item]
            return cell
        } else if collectionView.tag == 2 {
            let cell = collectionView.dequeue(Reusable.repeatCell, for: indexPath)
            cell.textLabel.text = repeatList[indexPath.item]
            return cell
        }
        
        return UICollectionViewCell()
        //        let cell = collectionView.dequeue(Reusable.categoryCell, for: indexPath)
        //
        //        cell.textLabel.text = categoryList[indexPath.item]
        //        return cell
    }
}

extension MogakInitViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 1 {
            let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
            
            // 배경색 확인 및 변경
            if cell.contentView.backgroundColor == UIColor(hex: "F1F3FA") {
                // 셀이 클릭되지 않은 상태일 때, 클릭된 상태로 변경
                cell.contentView.backgroundColor = UIColor(hex: "475FFD")
                cell.textLabel.textColor = UIColor(hex: "FFFFFF")
                // 셀 클릭 시 리스트에 카테고리 이름 추가
                if let cellText = cell.textLabel.text {
                    categorySelectedList.append(cellText)
                }
                print("클릭 시 categorySelectedList === \(categorySelectedList)")
            } else {
                // 셀이 이미 클릭된 상태일 때, 클릭되지 않은 상태로 변경
                cell.contentView.backgroundColor = UIColor(hex: "F1F3FA")
                cell.textLabel.textColor = UIColor(hex: "24252E")
                if let cellText = cell.textLabel.text {
                    if categorySelectedList.contains(cellText) {
                        categorySelectedList.removeAll { element in
                            return element == cellText
                        }
                    }
                    print("다시 한 번 클릭 시 categorySelectedList === \(categorySelectedList)")
                }
            }
        } else if collectionView.tag == 2 {
            let cell = collectionView.cellForItem(at: indexPath) as! RepeatCell
            
            // 배경색 확인 및 변경
            if cell.contentView.backgroundColor == UIColor(hex: "EEF0F8") {
                // 셀이 클릭되지 않은 상태일 때, 클릭된 상태로 변경
                cell.contentView.backgroundColor = UIColor(hex: "475FFD")
                cell.textLabel.textColor = UIColor(hex: "FFFFFF")
                // 셀 클릭 시 리스트에 카테고리 이름 추가
                if let cellText = cell.textLabel.text {
                    repeatSelectedList.append(cellText)
                }
                print("클릭 시 repeatSelectedList === \(repeatSelectedList)")
            } else {
                // 셀이 이미 클릭된 상태일 때, 클릭되지 않은 상태로 변경
                cell.contentView.backgroundColor = UIColor(hex: "EEF0F8")
                cell.textLabel.textColor = UIColor(hex: "24252E")
                if let cellText = cell.textLabel.text {
                    if repeatSelectedList.contains(cellText) {
                        repeatSelectedList.removeAll { element in
                            return element == cellText
                        }
                    }
                    print("다시 한 번 클릭 시 repeatSelectedList === \(repeatSelectedList)")
                }
            }
            
        }
        //        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        //
        //        // 배경색 확인 및 변경
        //        if cell.contentView.backgroundColor == UIColor(hex: "F1F3FA") {
        //            // 셀이 클릭되지 않은 상태일 때, 클릭된 상태로 변경
        //            cell.contentView.backgroundColor = UIColor(hex: "475FFD")
        //            cell.textLabel.textColor = UIColor(hex: "FFFFFF")
        //            // 셀 클릭 시 리스트에 카테고리 이름 추가
        //            if let cellText = cell.textLabel.text {
        //                categorySelectedList.append(cellText)
        //            }
        //            print("클릭 시 categorySelectedList === \(categorySelectedList)")
        //        } else {
        //            // 셀이 이미 클릭된 상태일 때, 클릭되지 않은 상태로 변경
        //            cell.contentView.backgroundColor = UIColor(hex: "F1F3FA")
        //            cell.textLabel.textColor = UIColor(hex: "24252E")
        //            if let cellText = cell.textLabel.text {
        //                if categorySelectedList.contains(cellText) {
        //                    categorySelectedList.removeAll { element in
        //                        return element == cellText
        //                    }
        //                }
        //                print("다시 한 번 클릭 시 categorySelectedList === \(categorySelectedList)")
        //            }
        //        }
    }
}

extension MogakInitViewController: UICollectionViewDelegateFlowLayout {
    // 셀 크기설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 1 {
            let label = UILabel().then {
                $0.font = UIFont.pretendard(.medium, size: 14)
                $0.text = categoryList[indexPath.item]
                $0.sizeToFit()
            }
            let size = label.frame.size
            
            return CGSize(width: size.width + 40, height: size.height + 16)
        } else if collectionView.tag == 2 {
            let label = UILabel().then {
                $0.font = UIFont.pretendard(.medium, size: 16)
                $0.text = repeatList[indexPath.item]
                $0.sizeToFit()
            }
            let size = label.frame.size
            
            return CGSize(width: size.width + 32, height: size.height + 32)
            
        }
        //        let label = UILabel().then {
        //            $0.font = UIFont.pretendard(.medium, size: 14)
        //            $0.text = categoryList[indexPath.item]
        //            $0.sizeToFit()
        //        }
        //        let size = label.frame.size
        //
        //        return CGSize(width: size.width + 40, height: size.height + 16)
        return CGSize()
    }
}

