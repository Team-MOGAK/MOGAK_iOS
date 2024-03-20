//
//  JogakSimpleModalViewController.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/20.
//

import Foundation
import UIKit
import SnapKit

/// 조각에 대한 간단한 정보를 나타내주는 조각 바텀 모달(조각 눌렀을 떄 나오는 바텀 모달)
class JogakSimpleModalViewController: UIViewController {
    var mogakCategory: String = ""
    let mogakCategoryColor: String = "475FFD"
    var jogakData: JogakDetail = JogakDetail(jogakID: 0, mogakTitle: "", category: "", title: "", isRoutine: false, days: [], startDate: "", endDate: "", isAlreadyAdded: false, achievements: 0)
    
    /// 조각 삭제 시작 클로저
    var startDeleteJogak: (() -> ())? = nil
    
    /// 어떤 카테고리에 속하는지
    private lazy var categoryLabel: CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 4, bottom: 4, left: 10, right: 10)
        label.numberOfLines = 1
        label.font = DesignSystemFont.semibold14L150.value
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    /// 조각 제목
    private lazy var jogakTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.font = DesignSystemFont.medium18140.value
        return label
    }()
    
    /// 루틴지정 라벨 + 반복 요일(stack)
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
    
    /// 반복 요일 + 반복 설정 토클(현재 사용 x)
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
    
    /// 루틴 지정 label
    private lazy var routineLabel: UILabel = {
        let label = UILabel()
        label.text = "루틴지정"
        label.font = DesignSystemFont.semibold14L150.value
        return label
    }()
    
    /// 루틴으로 지정된 요일 label
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
    
    /// 기간 label
    lazy var termLabel: UILabel = {
        let label = UILabel()
        label.text = "기간"
        label.textColor = DesignSystemColor.gray5.value
        label.numberOfLines = 1
        label.font = DesignSystemFont.semibold14L150.value
        return label
    }()
    
    /// 정확한 기간 label(ex. 2024년 03월 08일 ~ 2024년 04월 09일)
    lazy var termTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemColor.gray5.value
        label.numberOfLines = 1
        label.font = DesignSystemFont.regular16L150.value
        return label
    }()
    
    /// 삭제 버튼
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
    
    /// 편집 버튼
    lazy var editBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("수정", for: .normal)
        btn.backgroundColor = DesignSystemColor.signature.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.white.value, for: .normal)
        btn.titleLabel?.font = DesignSystemFont.medium16L100.value
        //btn.addTarget(self, action: #selector(editBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    /// 삭제버튼과 편집버튼이 들어있는 stack
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

    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        labelSetting()
        routineLabelSetting()
        termLabelSetting()
        configureLayout()
        self.view.backgroundColor = .white
    }
    
    /// 각종 라벨들에 데이터 넣어주기(ex. 카테고리 라벨 내용, 카테고리 라벨 글자색, 카테고리 라벨 배경 색 등)
    func labelSetting() {
        categoryLabel.text = mogakCategory
        categoryLabel.textColor = UIColor(hex: mogakCategoryColor)
        categoryLabel.backgroundColor = UIColor(hex: mogakCategory).withAlphaComponent(0.1)
        
        jogakTitleLabel.text = jogakData.title
    }
    
    /// 루틴 라벨 설정(ex. 루틴이 아닐 경우 -> routineStack 안보임)
    func routineLabelSetting() {
        if !jogakData.isRoutine {
            routineStack.isHidden = true
        } else {
            if let days = jogakData.daysSetting {
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
    
    //MARK: - 루틴의 경우 시작 일, 종료일 표시
    /// 루틴의 경우 시작 일, 종료일 표시
    func termLabelSetting() {
        if let endDate = jogakData.endDate,
           let startDate = jogakData.startDate {
            let endDateArr = endDate.components(separatedBy: "-")
            let startDateArr = startDate.components(separatedBy: "-")
            
            termTimeLabel.text = startDateArr[0]+"년" + startDateArr[1] + "월" + startDateArr[2] + "일 ~" + endDateArr[0]+"년" + endDateArr[1] + "월" + endDateArr[2] + "일"
        } else {
            termTimeLabel.text = "미지정"
        }
    }
    
    //MARK: - 조각 삭제 버튼 클릭
    /// 조각 삭제 버튼 클릭
    @objc func deleteBtnTapped() {
        self.dismiss(animated: true)
        guard let startDeleteJogak = self.startDeleteJogak else { return }
        startDeleteJogak()
        
    }
    
    @objc func editBtnTapped() {
        print(#fileID, #function, #line, "- 네 버튼 클릭")
        let jogakEditVC = JogakEditViewController()
        //self.navigationController?.pushViewController(jogakEditVC, animated: true)
        //self.dismiss(animated: true)
    }
    
}

extension JogakSimpleModalViewController {
    //MARK: - view들 레이아웃 잡아주기
    /// view들 레이아웃 잡아주기
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
