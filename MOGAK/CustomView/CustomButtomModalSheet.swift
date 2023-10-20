//
//  CustomButtomSheet.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/18.
//

import Foundation
import UIKit
import SnapKit

///아래에 위치하는 모달창
class CustomBottomModalSheet: UIViewController {
    //MARK: - properties
    //modal높이
    var bottomHeight: CGFloat = 300.0
    
    //bottomModalSheet가 view의 상단에서 떨어진 거리
    private var bottomSheetViewTopConstraint: Constraint!
    
    //기존의 화면을 흐려지게 함(즉, 모달의 배경이 되는 화면이 보이도록 함)
    private let dimmedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        return view
    }()
    
    //MARK: - 실제 바텀 모달시트뷰
    // vc를 메모리에 올릴때 UIView생성후 주입시켜주세요!!
    var bottomModalSheetView: UIView!
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 3
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGestureRecognizer()
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomModalSheet()
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

}

extension CustomBottomModalSheet {
    private func configureLayout() {
        self.view.addSubviews(dimmedBackgroundView, bottomModalSheetView, indicatorView)
        
        dimmedBackgroundView.alpha = 0.7
        dimmedBackgroundView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        
        //safeAreaInset는 경계 영역값 -> safeAreaInset.bottom은 safeArea를 제외한 아랫부분을 의미한다
        //safeAreaLayoutGuide.layoutFrame -> 안전영역이 가지는 영역을 의미한다
        //safeAreaLayoutGuide.layoutFrame.height -> 안전영역이 가지는 높이
        let topConstant = view.safeAreaInsets.bottom + view.safeAreaLayoutGuide.layoutFrame.height
        bottomModalSheetView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            self.bottomSheetViewTopConstraint = make.top.equalToSuperview().offset(topConstant).constraint
        }

        indicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bottomModalSheetView.snp.top).offset(12)
            make.width.equalTo(100)
            make.height.equalTo(5)
        }
    }
}

