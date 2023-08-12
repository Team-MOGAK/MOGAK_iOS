//
//  CircularProgressView.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/08/09.
//

import UIKit
import SnapKit
import Then

class CircularProgressView : UIView, UISheetPresentationControllerDelegate{
    
    
//MARK: - Properties
    
    private lazy var backgroundLayer : CAShapeLayer = {
        let backgroundLayer = CAShapeLayer()
        return backgroundLayer
    }()
    
    private lazy var progressLayer : CAShapeLayer = {
        let progressLayer  = CAShapeLayer()
        return progressLayer
    }()
    
     let timeLabel : UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont(name: "Pretendard-Medium", size: 52)
        return timeLabel
    }()
    
    private var circularPath : UIBezierPath{        //radius 원의 크기
        UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: 170, startAngle: CGFloat(-Double.pi / 2 ), endAngle: CGFloat(3 * Double.pi / 2), clockwise: true
        )
        
    }
    //초기시간
    var secondsLeft : Int = 5
    
    private var timer : Timer?
    
    private let animationName = "progressAnimation"
    
//MARK: -  init
    required init?(coder : NSCoder){
        fatalError("Not implemented")
    }
    
    override init(frame : CGRect){
        super.init(frame : frame)
        
        self.updateTimerLabel()
        
        self.backgroundLayer.path = self.circularPath.cgPath
        self.backgroundLayer.fillColor = UIColor.clear.cgColor
        self.backgroundLayer.lineCap = .round
        self.backgroundLayer.lineWidth = 20.0
        self.backgroundLayer.strokeEnd = 1.0
        self.backgroundLayer.strokeColor = UIColor(red: 0.203, green: 0.218, blue: 0.312, alpha: 1).cgColor
        
        
        self.progressLayer.path = self.circularPath.cgPath
        self.progressLayer.fillColor = UIColor.clear.cgColor
        self.progressLayer.lineCap = .round
        self.progressLayer.lineWidth = 20.0
        self.progressLayer.strokeEnd = 0
        self.progressLayer.strokeColor = UIColor(red: 0.278, green: 0.373, blue: 0.992, alpha: 1).cgColor
        
        setUI()
    }
    
    deinit{
        self.timer?.invalidate()
        self.timer = nil
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.backgroundLayer.path = self.circularPath.cgPath
        self.progressLayer.path = self.circularPath.cgPath
    }
    
    func setUI(){
        
        [timeLabel].forEach{addSubview($0)}
        [backgroundLayer,progressLayer].forEach{layer.addSublayer($0)}
        
        timeLabel.snp.makeConstraints{
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
//MARK: - Start
    @objc func Timerstart(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.secondsLeft -= 1
            self?.updateTimerLabel()
            if self?.secondsLeft == 0 {
                self?.Timerstop()
                
            }
        }
        //Animation
        self.progressLayer.removeAnimation(forKey: self.animationName)
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = TimeInterval(secondsLeft)
        circularProgressAnimation.toValue = 1.0
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        self.progressLayer.add(circularProgressAnimation,forKey: self.animationName)
    }
    
    
//MARK: - UpdateTime
    func updateTimerLabel(){
        let seconds = self.secondsLeft % 60
        let minutes = (self.secondsLeft / 60) % 60
        let hours = self.secondsLeft / 3600
        
        if self.secondsLeft < 10 {
            self.timeLabel.textColor = UIColor(red: 0.278, green: 0.373, blue: 0.992, alpha: 1)
            
        } else {
            self.timeLabel.textColor = UIColor(red: 0.278, green: 0.373, blue: 0.992, alpha: 1)
            
        }
        
        //UIView.transition(with: self.timeLabel, duration: 0.3, options: .transitionFlipFromBottom){ label 애니메이션
        UIView.transition(with: self.timeLabel, duration: 0.3, options: .beginFromCurrentState){
            if self.secondsLeft > 0{
                self.timeLabel.text = String(format : " %02d : %02d : %02d", hours, minutes, seconds)
            }else{
                self.timeLabel.text = "00 : 00 : 00"
            }
        }completion: { animated in
            
        }
    }
//MARK: - 타이머 정지
    //초기화
    @objc  func Timerstop(){
        self.timer?.invalidate()
        self.secondsLeft = 0
        self.updateTimerLabel()
    }
}
//MARK: - extension : 일시정지, 이어서 시작
extension CircularProgressView {
    private var isPaused: Bool {
        return timer?.isValid == false
    }
    
    // 타이머와 애니메이션 일시 중지
    func pauseTimer() {
        guard !isPaused else { return }
        timer?.invalidate()
        pauseLayer(layer: progressLayer)
        pauseLabelAnimation() // 타이머 레이블 애니메이션 일시 중지
        print("pause")
    }
    
    // 타이머와 애니메이션 다시 시작
    func resumeTimer() {
        guard isPaused else { return }
        resumeLayer(layer: progressLayer)
        resumeLabelAnimation() // 타이머 레이블 애니메이션 다시 시작
        print("resume")
    }
    
    // 레이어의 애니메이션 일시 중지
    private func pauseLayer(layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    // 레이어의 애니메이션 다시 시작
    private func resumeLayer(layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = CACurrentMediaTime() - pausedTime
        layer.beginTime = timeSincePause
    }
    
    // 타이머 레이블 애니메이션 일시 중지
    private func pauseLabelAnimation() {
        timeLabel.layer.pauseAnimation()
    }
    
    // 타이머 레이블 애니메이션 다시 시작
    private func resumeLabelAnimation() {
        timeLabel.layer.resumeAnimation()
    }
}

extension CALayer {
    // 레이어 애니메이션 일시 중지
    func pauseAnimation() {
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }
    
    // 레이어 애니메이션 다시 시작
    func resumeAnimation() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let timeSincePause = CACurrentMediaTime() - pausedTime
        beginTime = timeSincePause
    }
}
