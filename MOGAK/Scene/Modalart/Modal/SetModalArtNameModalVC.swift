//
//  SetModalArtNameVC.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/27.
//

import Foundation
import UIKit
import SnapKit

///아래에 위치하는 모달창
class SetModalArtNameModalVC: UIViewController{
    //MARK: - properties
    //modal높이
    var bottomHeight: CGFloat = 252
    
    //bottomModalSheet가 view의 상단에서 떨어진 거리
    var bottomSheetViewTopConstraint: Constraint!
    
    var modalArtTitle: String = ""
    
    var titleBgColor: String!

    let titleColorPalette: [String] = ["475FFD", "11D796", "009967", "FF2323", "D9D9D9", "F98A08", "FF6827", "9C31FF"]
    
    //기존의 화면을 흐려지게 함(즉, 모달의 배경이 되는 화면이 보이도록 함)
    private let dimmedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        return view
    }()
    
    //MARK: - 실제 바텀 모달시트뷰
    // vc를 메모리에 올릴때 UIView생성후 주입시켜주세요!!
    var bottomModalSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 3
        
        return view
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "나의 가장 큰 목표는?"
        label.numberOfLines = 1
        label.font = DesignSystemFont.semibold14L150.value
        return label
    }()
    
    var titleSetTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이루고픈 목표를 입력해 주세요."
        textField.setPlaceholderColor(DesignSystemColor.gray3.value)
        textField.textColor = .black
        textField.autocorrectionType = .no
        return textField
    }()
    
    var colorStackView: UIStackView = {
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.spacing = 16
        stk.distribution = .fillEqually
        return stk
    }()
    
    var colorScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("취소", for: .normal)
        btn.backgroundColor = DesignSystemColor.gray2.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.black.value, for: .normal)
        btn.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        return btn
    }()

    var completeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("완료", for: .normal)
        btn.backgroundColor = DesignSystemColor.gray3.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.white.value, for: .normal)
        btn.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        return btn
    }()
    
    var btnStackView: UIStackView = {
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.spacing = 10
        stk.distribution = .fillEqually
        return stk
    }()
    
    var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if modalArtTitle != "" {
            titleSetTextField.text = modalArtTitle
        }
        
        setupGestureRecognizer()
        configureLayout()
        mainModalArtTitleColors()
        collectionViewSetUp()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomModalSheet()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    //MARK: - GestureRecognizer 세팅 작업
    private func setupGestureRecognizer() {
        // 흐린 부분 탭할 때, 바텀시트를 내리는 TapGesture
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedBackgroundViewTapped(_:)))
        dimmedBackgroundView.addGestureRecognizer(dimmedTap)
        dimmedBackgroundView.isUserInteractionEnabled = true
        
        // 스와이프 했을 때, 바텀시트를 내리는 swipeGesture
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(panGesture))
        swipeGesture.direction = .down
        bottomModalSheetView.addGestureRecognizer(swipeGesture)
    }
    
    //MARK: - 모달이 나옴
    private func showBottomModalSheet() {
        let safeAreaHeight: CGFloat = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding: CGFloat = view.safeAreaInsets.bottom

        let changeConstant = (safeAreaHeight + bottomPadding) - bottomHeight
        self.bottomSheetViewTopConstraint.update(offset: changeConstant)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.dimmedBackgroundView.alpha = 0.5
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    //MARK: - 모달 사라지게 함
    private func hideBottomSheetAndGoBack() {
        let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding = view.safeAreaInsets.bottom
        self.bottomSheetViewTopConstraint.update(offset: bottomPadding + safeAreaHeight)
        
        UIView.animate(withDuration: 0.5, delay: 0 , options:.curveLinear, animations: {
            self.dimmedBackgroundView.alpha = 0.0
            
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil { //현재 모달 전체 뷰가 보여지고 있지 않다면
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    //MARK: - 모달 뒤 배경을 눌렀을 경우
    @objc private func dimmedBackgroundViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideBottomSheetAndGoBack()
    }
    
    //MARK: - 바텀시트를 아래로 스와이프하면 바텀시트가 내렴감
    @objc func panGesture(_ recognizer: UISwipeGestureRecognizer) {
        if recognizer.state == .ended {
            switch recognizer.direction {
            case .down:
                hideBottomSheetAndGoBack()
            default:
                break
            }
        }
    }
    
    //MARK: - 키보드 올라올때 모달위치 다시 세팅
    @objc func keyboardWillShow(_ sender: Notification) {
        guard let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let bottomPadding: CGFloat = self.view.safeAreaInsets.bottom
        let safeAreaHeight: CGFloat = self.view.safeAreaLayoutGuide.layoutFrame.height

        let changeConstant = (safeAreaHeight + bottomPadding) - (bottomHeight + keyboardSize.height)
        self.bottomSheetViewTopConstraint.update(offset: changeConstant)
    }
    
    //MARK: - 키보드 내려갈떄 모달위치를 다시 수정함
    @objc func keyboardWillHide(_ sender: Notification) {
        guard let screenSize = self.view.window?.windowScene?.screen.bounds else { return }
        let bottomPadding: CGFloat = self.view.safeAreaInsets.bottom
        self.bottomModalSheetView.frame.origin.y = screenSize.height - (self.bottomHeight + bottomPadding + 10)
    }
        
        //MARK: - color palette만들기
    private func mainModalArtTitleColors() {
        titleColorPalette.map { color in
            let view: UIView = {
                let view = UIView()
                view.backgroundColor = UIColor(hex: color)
                
                view.layer.cornerRadius = 20 //width가 40이니까 그거의 절반인 20으로만들기
                view.clipsToBounds = true
                view.snp.makeConstraints { make in
                    make.size.equalTo(40)
                }
                return view
            }()
            return view
        }
        .forEach(colorStackView.addArrangedSubview)
    }
        
    @objc func cancelBtnTapped(_ sender: UIButton) {
        print(#fileID, #function, #line, "- 취소버튼 클릭")
        self.dismiss(animated: true)
    }
    
    @objc func completeBtnTapped(_ sender: UIButton) {
        print(#fileID, #function, #line, "- 완료버튼 클릭")
        self.dismiss(animated: true)
    }
    
    //MARK: - 컬러 팔레트의 컬러를 선택했을때 해당 컬러 안에 넣어야 함
    @objc func colorTapGesture(_ sender: UITapGestureRecognizer) -> UIView{
        let view: UIView = {
            let view = UIView()
            view.backgroundColor = DesignSystemColor.white.value
            
            view.layer.cornerRadius = 15 //width가 40이니까 그거의 절반인 20으로만들기
            view.clipsToBounds = true
            view.snp.makeConstraints { make in
                make.size.equalTo(30)
            }
            return view
        }()
        return view
    }
    
    func collectionViewSetUp() {
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        colorCollectionView.dataSource = self
//        colorCollectionView.delegate = self
    }

}

extension SetModalArtNameModalVC {
    private func configureLayout() {
        self.view.addSubviews(dimmedBackgroundView, bottomModalSheetView)
        
//        self.bottomModalSheetView.addSubviews(indicatorView, titleLabel, titleSetTextField, colorScrollView, btnStackView)
        self.bottomModalSheetView.addSubviews(indicatorView, titleLabel, titleSetTextField, colorCollectionView, btnStackView)
        
//        self.colorScrollView.addSubview(colorStackView)
        self.btnStackView.addArrangedSubview(cancelBtn)
        self.btnStackView.addArrangedSubview(completeBtn)
        
        dimmedBackgroundView.alpha = 0.7
        dimmedBackgroundView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        
        let topConstant = view.safeAreaInsets.bottom + view.safeAreaLayoutGuide.layoutFrame.height
        bottomModalSheetView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            self.bottomSheetViewTopConstraint = make.top.equalToSuperview().offset(topConstant).constraint
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(bottomModalSheetView.snp.top).offset(40)
            make.leading.equalToSuperview().offset(20)
        }
        
        titleSetTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        colorCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleSetTextField.snp.bottom).offset(26)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
//        colorScrollView.snp.makeConstraints { make in
//            make.top.equalTo(titleSetTextField.snp.bottom).offset(26)
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview()
//            make.height.equalTo(40)
//        }
        
//        colorStackView.snp.makeConstraints { make in
//            make.top.equalTo(colorScrollView.snp.top)
//            make.leading.equalTo(colorScrollView.snp.leading)
//            make.bottom.equalTo(colorScrollView.snp.bottom)
//            make.trailing.equalTo(colorScrollView.snp.trailing)
//        }
        
        btnStackView.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleSetTextField.snp.bottom).offset(99)
            make.leading.equalToSuperview().offset(20)
        }
     
        indicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bottomModalSheetView.snp.top).offset(12)
            make.width.equalTo(100)
            make.height.equalTo(5)
        }
    }
}

extension SetModalArtNameModalVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(#fileID, #function, #line, "- 변경된거 탄🐿️")
        let currentText = textField.text ?? ""
        
        guard let stringLength = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringLength, with: string)
        return updatedText.count <= 8
    }
    
    
}


extension SetModalArtNameModalVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titleColorPalette.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
        
        cell.color = UIColor(hex: titleColorPalette[indexPath.row])
        if titleColorPalette[indexPath.row] == titleBgColor {
//            cell.isSelected = true
            cell.innerView.backgroundColor = .white
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
        }
        cell.setUpColorView()
        cell.setUpInnerView()
        
        print(#fileID, #function, #line, "- cell.colr: \(titleColorPalette[indexPath.row]), cell.isSelected:\(cell.isSelected)" )
        return cell
    }
}

//extension SetModalArtNameModalVC: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(#fileID, #function, #line, "- <#comment#>")
//        
//    }
//}

