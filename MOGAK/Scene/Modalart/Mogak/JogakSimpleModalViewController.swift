//
//  JogakSimpleModalViewController.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/20.
//

import Foundation
import UIKit
import SnapKit

class JogakSimpleModalViewController: UIViewController {
    var mogakCategory: String = ""
    let mogakCategoryColor: String = "475FFD"
    var jogakData: JogakDetail = JogakDetail(jogakID: 0, mogakTitle: "", category: "", title: "", isRoutine: false, days: [], startDate: "", endDate: "", isAlreadyAdded: false, achievements: 0)
    
    var startDeleteJogak: (() -> ())? = nil
    private lazy var categoryLabel: CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 4, bottom: 4, left: 10, right: 10)
        label.numberOfLines = 1
        label.font = DesignSystemFont.semibold14L150.value
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var jogakTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.font = DesignSystemFont.medium18140.value
        return label
    }()
    
    private lazy var routineStack: UIStackView = {
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.distribution = .fill
        stk.addArrangedSubview(routineLabel)
//        stk.addArrangedSubview(routineDayStack)
        stk.addArrangedSubview(routineDayLabel)
        return stk
    }()
    
    private lazy var routineDayStack: UIStackView = {
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.spacing = 20
        stk.distribution = .fill
        stk.addArrangedSubview(routineDayLabel)
        stk.addArrangedSubview(routineToggle)
        return stk
    }()
    
    private lazy var routineLabel: UILabel = {
        let label = UILabel()
        label.text = "루틴지정"
        label.font = DesignSystemFont.semibold14L150.value
        return label
    }()
    
    private lazy var routineDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemColor.gray5.value
        label.font = DesignSystemFont.regular16L150.value
        return label
    }()
    
    private lazy var routineToggle: UISwitch = {
        let uiSwitch = UISwitch()
        return uiSwitch
    }()
    
    lazy var termLabel: UILabel = {
        let label = UILabel()
        label.text = "기간"
        label.textColor = DesignSystemColor.gray5.value
        label.numberOfLines = 1
        label.font = DesignSystemFont.semibold14L150.value
        return label
    }()
    
    lazy var termTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemColor.gray5.value
        label.numberOfLines = 1
        label.font = DesignSystemFont.regular16L150.value
        return label
    }()
    
    lazy var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("삭제", for: .normal)
        btn.backgroundColor = DesignSystemColor.signatureBag.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.signature.value, for: .normal)
        btn.titleLabel?.font = DesignSystemFont.medium16L100.value
        btn.addTarget(self, action: #selector(deleteBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var editBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("수정", for: .normal)
        btn.backgroundColor = DesignSystemColor.signature.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.white.value, for: .normal)
        btn.titleLabel?.font = DesignSystemFont.medium16L100.value
        btn.addTarget(self, action: #selector(editBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var btnstk: UIStackView = {
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.spacing = 10
        stk.distribution = .fillEqually
        stk.addArrangedSubview(deleteBtn)
        stk.addArrangedSubview(editBtn)
        return stk
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        labelSetting()
        routineLabelSetting()
        termLabelSetting()
        configureLayout()
        self.view.backgroundColor = .white
    }
    
    func labelSetting() {
        categoryLabel.text = mogakCategory
        categoryLabel.textColor = UIColor(hex: mogakCategoryColor)
        categoryLabel.backgroundColor = UIColor(hex: mogakCategory).withAlphaComponent(0.1)
        
        jogakTitleLabel.text = jogakData.title
    }
    
    func routineLabelSetting() {
        if !jogakData.isRoutine {
            routineStack.isHidden = true
        } else {
            if let days = jogakData.days {
                if days.isEmpty {
                    routineDayLabel.text = "미지정"
                } else {
                    routineDayLabel.text = days.joined(separator: ",")
                }
            } else {
                routineDayLabel.text = "미지정"
            }
        }
        
    }
    
    func termLabelSetting() {
        if let endDate = jogakData.endDate,
           let startDate = jogakData.startDate {
            let endDateArr = endDate.components(separatedBy: "-")
            let startDateArr = startDate.components(separatedBy: "-")
            
            termTimeLabel.text = endDateArr[0]+"년" + endDateArr[1] + "월" + endDateArr[2] + "일 ~" + startDateArr[0]+"년" + startDateArr[1] + "월" + startDateArr[2] + "일"
        } else {
            termTimeLabel.text = "미지정"
        }
    }
    
    
    @objc func deleteBtnTapped() {
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
            guard let startDeleteJogak = self.startDeleteJogak else { return }
            startDeleteJogak()
        }
        self.dismiss(animated: true)
        self.present(bottomSheetVC, animated: true)
    }
    
    @objc func editBtnTapped() {
        print(#fileID, #function, #line, "- 네 버튼 클릭")
    
        self.dismiss(animated: true)
    }
    
}

extension JogakSimpleModalViewController {
    func configureLayout() {
        self.view.addSubviews(categoryLabel, jogakTitleLabel, routineStack, termLabel, termTimeLabel, btnstk)
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.leading.equalToSuperview().offset(20)
        }
        
        jogakTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
        }
        
        routineStack.snp.makeConstraints { make in
            if jogakData.isRoutine {
                make.height.equalTo(24)
            } else {
                make.height.equalTo(0)
            }
            make.top.equalTo(jogakTitleLabel.snp.bottom).offset(13)
            make.leading.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        termLabel.snp.makeConstraints { make in
            if jogakData.isRoutine {
                make.top.equalTo(routineLabel.snp.bottom).offset(13)
            } else {
                make.top.equalTo(jogakTitleLabel.snp.bottom).offset(13)
            }
            
            make.leading.equalToSuperview().offset(20)
        }
        
        termTimeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(termLabel.snp.centerY)
        }
        
        btnstk.snp.makeConstraints { make in
            make.height.equalTo(52)
            if jogakData.isRoutine {
                make.top.equalTo(termTimeLabel.snp.bottom).offset(6)
            } else {
                make.top.equalTo(termTimeLabel.snp.bottom).offset(15)
            }
            
            make.leading.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
    }
}

#if DEBUG
import SwiftUI
struct Preview10: UIViewControllerRepresentable {
    
    // 여기 ViewController를 변경해주세요
    func makeUIViewController(context: Context) -> UIViewController {
        JogakSimpleModalViewController()
    }
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
}

struct ViewController_PreviewProvider10: PreviewProvider {
    static var previews: some View {
        Group {
            Preview()
                .edgesIgnoringSafeArea(.all)
                .previewDisplayName("Preview")
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
        }
    }
}
#endif
