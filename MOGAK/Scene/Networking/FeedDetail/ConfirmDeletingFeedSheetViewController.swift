//
//  ConfirmDeletingFeedSheetViewController.swift
//  MOGAK
//
//  Created by 이재혁 on 2023/08/19.
//

import UIKit

class ConfirmDeletingFeedSheetViewController: UIViewController, UISheetPresentationControllerDelegate {

    // MARK: - UI 요소들
    // 삭제하시겠어요?
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = "글을 정말 삭제하시겠어요?"
        label.font = UIFont.pretendard(.semiBold, size: 20)
        label.textColor = UIColor(hex: "24252E")
        label.textAlignment = .center
        return label
    }()
    
    private let textLabel : UILabel = {
        let label = UILabel()
        label.text = "다시 복원할 수 없어요 :(\n신중하게 선택해주세요!"
        label.font = UIFont.pretendard(.regular, size: 14)
        label.textColor = UIColor(hex: "24252E")
        label.textAlignment = .center
        label.alpha = 0.6
        label.numberOfLines = 2
        return label
    }()
    
    private let noButton: UIButton = UIButton().then {
        $0.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        $0.setTitle("아니요", for: .normal)
        $0.setTitleColor(UIColor(hex: "475FFD"), for: .normal)
        $0.backgroundColor = UIColor(hex: "E8EBFE")
        $0.layer.cornerRadius = 10
        $0.contentEdgeInsets = UIEdgeInsets(top: 17, left: 62, bottom: 17, right: 61)
        
        $0.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
    }
    
    @objc private func noButtonTapped() {
        print("no")
        self.dismiss(animated: true, completion: nil)
    }
    
    private let yesButton: UIButton = UIButton().then {
        $0.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        $0.setTitle("네", for: .normal)
        $0.setTitleColor(UIColor(hex: "FFFFFF"), for: .normal)
        $0.backgroundColor = UIColor(hex: "475FFD")
        $0.layer.cornerRadius = 10
        $0.contentEdgeInsets = UIEdgeInsets(top: 17, left: 77, bottom: 17, right: 77)
        
        $0.addTarget(self, action: #selector(yesButtonTapped), for: .touchUpInside)
    }
    
    @objc private func yesButtonTapped() {
        print("yes")
    }
    
    private func configureView() {
        view.addSubviews(titleLabel, textLabel, noButton, yesButton)
        
        titleLabel.snp.makeConstraints({
            $0.top.equalToSuperview().offset(50)
            $0.left.right.equalToSuperview().inset(20)
        })
        textLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(20)
        })
        noButton.snp.makeConstraints({
            $0.left.equalToSuperview().inset(20)
            $0.top.equalTo(textLabel.snp.bottom).offset(50)
        })
        yesButton.snp.makeConstraints({
            $0.right.equalToSuperview().inset(20)
            $0.top.equalTo(textLabel.snp.bottom).offset(50)
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSheet()
        configureView()

        // Do any additional setup after loading the view.
    }
    

    private func setupSheet() {
            //isModalInPresentation = true : sheet가 dismiss되지 않음!!! default는 false
            
            if let sheet = sheetPresentationController {
                /// 드래그 멈추면 그 위치에 멈추는 지점: default는 large()
                //sheet.detents = [.medium(), .large()]
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom { context in
                        return context.maximumDetentValue * 0.3
                    }
                    ]
                } else {
                    // Fallback on earlier versions
                }
                /// 초기화 드래그 위치
                sheet.selectedDetentIdentifier = .large
                /// sheet
                //sheet.largestUndimmedDetentIdentifier = .medium -> 이게 배경색 흐려지게 하는거였다.. 왜그런진 모르겠다
                ///
                sheet.prefersGrabberVisible = true
                ///
                sheet.delegate = self
                ///
                sheet.presentingViewController.navigationController?.setNavigationBarHidden(true, animated: false)
                //sheet.presentingViewController.navigationController?.isNavigationBarHidden = true

            }
        }

}
