//
//  ScheduleTimer.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/08/05.
//

import UIKit
import SnapKit
import Then

class ScheduleTimerVC : UIViewController, UISheetPresentationControllerDelegate{
    
//MARK: - Properties
    
    private lazy var popButton : UIButton = {
        let popButton = UIButton()
        popButton.backgroundColor = .clear //백그라운드색
        popButton.setImage(UIImage(named: "backButton_white"), for: .normal)
        popButton.addTarget(self, action: #selector(ScheduleCancel), for: .touchUpInside)
        return popButton
    }()
    
    private lazy var grownLabel : UILabel = {
        let grownLabel = UILabel()
        grownLabel.backgroundColor = UIColor(hex: "#202A5F")
        grownLabel.textColor = .white
        grownLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
        grownLabel.layer.cornerRadius = 15
        grownLabel.clipsToBounds = true
        grownLabel.textAlignment = .center
        
        var grownLabelText = "지금 " + grownlabelcount.text! + "의 모각러들이 함께 성장하고 있어요!"
        grownLabel.text = grownLabelText
        
        return grownLabel
    }()
    
    var grownlabelcount : UILabel = {
        var grownlabelcount = UILabel()
        grownlabelcount.text = "3000명"
        return grownlabelcount
    }()
    
    private lazy var pauseButton : UIButton = {
        let pauseButton = UIButton()
        pauseButton.backgroundColor = UIColor.clear //백그라운드색
        pauseButton.setImage(UIImage(named: "stopButton"), for: .normal)
        pauseButton.layer.cornerRadius = 5 //둥글기
        pauseButton.addTarget(self, action: #selector(SchedulePause), for: .touchUpInside)
        return pauseButton
    }()
    
     var circularProgressView = CircularProgressView()
    
//MARK: - viewDidLoad
    override func viewDidLoad() {
        //self.navigationController?.navigationBar.isHidden = true
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.011, green: 0.022, blue: 0.092, alpha: 1)
        //self.navigationBar.barTintColor = UIColor(red: 0.011, green: 0.022, blue: 0.092, alpha: 1)
        
        setUI()
        changeTextFont()
    }
    
//MARK: - @objc
    
    @objc func ScheduleCancel(){
        circularProgressView.pauseTimer()
        
        lazy var scheduleCancel = ScheduleCancelModalVC()
        scheduleCancel.modalPresentationStyle = .formSheet
        self.present(scheduleCancel,animated: true)
        
        if let sheet = scheduleCancel.sheetPresentationController{
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom(){context in
                    return 239
                }]
            } else {
                sheet.detents = [.medium()]
                
            }
            sheet.delegate = self
            sheet.prefersGrabberVisible = true
        }
        print("Cancel Schedule")
    }
    
    @objc func SchedulePause(){
        circularProgressView.pauseTimer()
        
        lazy var schedulePause = PauseModalVC()
        schedulePause.modalPresentationStyle = .formSheet
        self.present(schedulePause,animated: true)
        
        if let sheet = schedulePause.sheetPresentationController{
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom(){context in
                    return 239
                }]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.delegate = self
            sheet.prefersGrabberVisible = true
        }
        print("Pause Schedule")
    }
    
    func changeTextFont(){
        guard let text = self.grownLabel.text else {return}
        
        let attributeString = NSMutableAttributedString(string : text)
        let font = UIFont(name: "Pretendard-SemiBold", size: 14)
        
        attributeString.addAttribute(.foregroundColor, value: UIColor.white, range: (text as NSString).range(of: "3000명"))
        
        attributeString.addAttribute(.font, value: font as Any, range: (text as NSString).range(of: "3000명"))
        
        self.grownLabel.attributedText = attributeString
    }
    
    func setUI(){
        [popButton,grownLabel,grownlabelcount,circularProgressView,pauseButton].forEach{view.addSubview($0)}
        
        popButton.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            $0.leading.equalToSuperview().inset(20)
        }
        circularProgressView.snp.makeConstraints{
            $0.width.height.equalTo(340)
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.centerX.centerY.equalToSuperview()
        }
        
        grownLabel.snp.makeConstraints{
            $0.top.equalTo(circularProgressView.snp.bottom).offset(65)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(37)
            $0.height.equalTo(30)
            $0.width.equalTo(316)
        }
        
        pauseButton.snp.makeConstraints{
            $0.top.equalTo(circularProgressView.timeLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            
        }
    }
}
































#if DEBUG
import SwiftUI
struct ScheduleTimerVCRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        ScheduleTimerVC()
    }
}
@available(iOS 13.0, *)
struct ScheduleTimerVCRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            if #available(iOS 14.0, *) {
                ScheduleTimerVCRepresentable()
                    .ignoresSafeArea()
                    .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                    .previewDevice(PreviewDevice(rawValue: "iPhone se3"))
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
} #endif
