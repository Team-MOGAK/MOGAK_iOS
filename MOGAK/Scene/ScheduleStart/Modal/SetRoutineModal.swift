//
//  PauseModalVC.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/08/11.
//

import UIKit
import SnapKit
import Then

class SetRoutineModal : UIViewController,UISheetPresentationControllerDelegate{
    
     lazy var jogaktitleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(hex: "24252E")
        return label
    }()
    
     let subtitleLabel : UILabel = {
        let label = UILabel()
         label.text = "이 조각은 루틴으로 지정되어 있어요!\n루틴을 해제하시겠어요?"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont(name: "Pretendard", size: 14)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        return label
    }()
    
    private lazy var stopButton : UIButton = {
        let stopButton = UIButton()
        stopButton.setTitle("완성하기",for : .normal) //타이틀
        stopButton.setTitleColor(.white, for : .normal) //글자 색
        stopButton.backgroundColor = UIColor(hex: "475FFD") //백그라운드색
        stopButton.layer.cornerRadius = 10 //둥글기
        stopButton.addTarget(self, action: #selector(ScheduleStop), for: .touchUpInside)
        return stopButton
    }()
    
    private lazy var keepGoButton : UIButton = {
        let keepGoButton = UIButton()
        keepGoButton.setTitle("삭제하기",for : .normal) //타이틀
        keepGoButton.setTitleColor(UIColor(hex: "475FFD"), for: .normal) //글자 색
        keepGoButton.backgroundColor = UIColor(hex: "#E8EBFE") //백그라운드색
        keepGoButton.layer.cornerRadius = 10 //둥글기
        keepGoButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        return keepGoButton
    }()
    
    let CellVC = ScheduleTableViewCell()
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        }
    
    //MARK: - setUI
    func setUI(){
        [jogaktitleLabel,subtitleLabel,stopButton,keepGoButton].forEach{view.addSubview($0)}
        jogaktitleLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(49)
        }
        
        subtitleLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(jogaktitleLabel.snp.bottom).offset(12)
        }
        
        stopButton.snp.makeConstraints{
            $0.width.equalTo(170)
            $0.height.equalTo(52)
            $0.bottom.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        keepGoButton.snp.makeConstraints{
            $0.width.equalTo(170)
            $0.height.equalTo(52)
            $0.bottom.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().inset(20)
            
        }
    }
    //MARK: - @objc func
    
    @objc func ScheduleStop(){
        print("ScheduleStop")
        self.dismiss(animated: true, completion: {
        })
    }
    @objc func dismissModal(){
        self.dismiss(animated: true){ [weak self] in
            
        }
    }
    
}











//Preview code
#if DEBUG
import SwiftUI
struct SetRoutineModalVCRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        SetRoutineModal()
    }
}
@available(iOS 13.0, *)
struct SelectJogakModalRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            if #available(iOS 14.0, *) {
                SetRoutineModalVCRepresentable()
                    .ignoresSafeArea()
                    .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                    .previewDevice(PreviewDevice(rawValue: "iPhone 15pro"))
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
} #endif
