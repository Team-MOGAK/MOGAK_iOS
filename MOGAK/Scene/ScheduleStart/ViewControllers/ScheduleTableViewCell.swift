//
//  ScheduleTableViewCell.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/07/24.
//

import UIKit
import SnapKit
import Then

class ScheduleTableViewCell : UITableViewCell, UISheetPresentationControllerDelegate,UITableViewDelegate {
    
    //MARK: - properties
    
    lazy var cellImage : UIImageView = {
        let cellImage = UIImageView()
        cellImage.backgroundColor = .clear //백그라운드색
        cellImage.layer.cornerRadius = 5 //둥글기
        cellImage.image  = UIImage(named: "emptySquareCheckmark")
        return cellImage
    }()
    
    lazy var cellLabel : UILabel = {
        let cellLabel = UILabel()
        cellLabel.numberOfLines = 2
        cellLabel.textAlignment = .left
        return cellLabel
    }()
    
    lazy var cellButton : UIButton = {
        let cellButton = UIButton()
        cellButton.setImage(UIImage(systemName : "ellipsis"), for: .normal)
        cellButton.tintColor = UIColor(hex: "#6E707B")
        cellButton.backgroundColor = .clear
        cellButton.addTarget(self, action: #selector(ButtonClicked), for: .touchUpInside)
        return cellButton
    }()
    
    lazy var recodelabel: UILabel? = {
        let label = UILabel()
        label.numberOfLines = 4
        label.font = UIFont(name: "PretendardVariable-Regular", size: 12)
        label.textColor = UIColor(red: 0.431, green: 0.441, blue: 0.483, alpha: 1)
        return label
    }()

    lazy var recodeimageView: UIImageView? = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let selectJogakModal = SelectJogakModal()
    var isRoutine = Bool()
    
//MARK: - @objc
    @objc func ButtonClicked(){
        guard let parentViewController = self.parentVC else {
            return
        }
        
        let setroutine = SetRoutineModal()
        let desetroutine = deSetRoutineModal()
        
        setroutine.modalPresentationStyle = .formSheet
        desetroutine.modalPresentationStyle = .formSheet
        
        //if cellImage.image == UIImage(named: "emptySquareCheckmark"){
        if isRoutine == false{
            parentViewController.present(desetroutine,animated: true)
        
            desetroutine.jogaktitleLabel.text = cellLabel.text
            
            if let desetsheet = desetroutine.sheetPresentationController{
                if #available(iOS 16.0, *) {
                    desetsheet.detents = [.custom { context in
                        return 200
                    }]
                    
                    desetsheet.delegate = self
                    desetsheet.prefersGrabberVisible = true
                }
                
            }
//MARK: - 루틴으로 지정되지 않은 조각

            desetroutine.pushClosure = {
                let vc = JogakEditViewController()
                        parentViewController.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            parentViewController.present(setroutine,animated: true)
            
            setroutine.jogaktitleLabel.text = cellLabel.text
            
            if let setsheet = setroutine.sheetPresentationController{
                if #available(iOS 16.0, *) {
                    setsheet.detents = [.custom { context in
                        return 200
                    }]
                    setsheet.delegate = self
                    setsheet.prefersGrabberVisible = true
                }
                
            }
//MARK: - 루틴으로 지정된 조각
            setroutine.pushClosure = {
                let vc = JogakEditViewController()
                        parentViewController.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        CellUI()
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
//MARK: - UI
    private func CellUI(){
        contentView.addSubview(cellImage)
        contentView.addSubview(cellLabel)
        contentView.addSubview(cellButton)
        contentView.addSubview(recodelabel!)
        contentView.addSubview(recodeimageView!)
        
        cellImage.snp.makeConstraints{
            $0.width.height.equalTo(20)
            $0.leading.equalTo(contentView).offset(10)
            $0.centerY.equalTo(contentView)
        }
        
        cellLabel.snp.makeConstraints{
            $0.centerY.equalTo(cellImage)
            $0.leading.equalTo(cellImage.snp.trailing).offset(10)
        }
        
        cellButton.snp.makeConstraints{
            $0.width.height.equalTo(30)
            $0.trailing.equalTo(contentView).offset(-16)
            $0.centerY.equalTo(contentView)
        }
        recodelabel?.snp.makeConstraints {
            $0.leading.equalTo(cellLabel.snp.trailing).offset(10)
               $0.top.equalTo(contentView).offset(10) // Adjust top constraint as needed
               $0.trailing.equalTo(contentView).offset(-16)
               $0.bottom.lessThanOrEqualTo(contentView).offset(-10) // Adjust bottom constraint as needed
               
               $0.height.greaterThanOrEqualTo(0) // 최소 높이를 0으로 설정하거나 필요에 따라 조절
        }
        
        recodeimageView?.snp.makeConstraints{
            $0.centerX.centerY.equalToSuperview()
        }
        
        layer.shadowColor = UIColor.darkGray.cgColor         //그림자 효과 추후 적용 예정
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowOpacity = 0.06
        contentView.layer.shadowRadius = 10
        
        
    }
    
    func calculateRecodelabelHeight() -> CGFloat {
        guard let recodelabel = self.recodelabel else {
            return 0
        }

        let label = UILabel()
        label.text = recodelabel.text // 실제 recodelabel의 텍스트를 사용합니다
        label.font = recodelabel.font // 실제 recodelabel의 폰트를 사용합니다
        label.numberOfLines = recodelabel.numberOfLines
        label.lineBreakMode = recodelabel.lineBreakMode

        let labelSize = label.sizeThatFits(CGSize(width: recodelabel.frame.width, height: CGFloat.greatestFiniteMagnitude))

        return labelSize.height
    }

}

extension UITableViewCell {
    var parentVC: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
