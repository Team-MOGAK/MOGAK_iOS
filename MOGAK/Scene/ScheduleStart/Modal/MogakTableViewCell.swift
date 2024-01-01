//
//  MogakTableViewCell.swift
//  MOGAK
//
//  Created by 안세훈 on 11/6/23.
//

import Foundation
import SnapKit
import Then
import Alamofire

class MogakTableViewCell: UITableViewCell {
    
    weak var parentViewController: SelectJogakModal?
    var jogakClickClosure : ((String) -> ())?
    
    
    private let MogakLabel : BasePaddingLabel = {
        let label = BasePaddingLabel(padding: UIEdgeInsets(top:12,left:20,bottom:12,right:20))
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var MogakView : UIView = {
        let view = UIView()
        return view
    }()
    
    
    let MogakButtonView : UIImageView = {
        let MogakButton = UIImageView()
        MogakButton.image = UIImage(systemName: "chevron.up")
        MogakButton.tintColor = DesignSystemColor.icongray.value
        return MogakButton
    }()
    
    
    //MARK: - StackViews
    
    lazy var MogakStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [MogakView])
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var JogakStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isHidden = true
        stackView.axis = .vertical
        stackView.spacing = 16
        //        let tapjogakStackView = UITapGestureRecognizer(target: self, action: #selector(JogakStackViewTap))
        //        stackView.addGestureRecognizer(tapjogakStackView)
        
        return stackView
    }()
    
    private lazy var cellStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [MogakStackView,JogakStackView])
        stackView.axis = .vertical
        return stackView
    }()
    
    
    //MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    //MARK: - SetUI
    
    private func setUI() {
        
        contentView.addSubviews(cellStackView,MogakButtonView)
        MogakView.addSubview(MogakLabel)
        
        cellStackView.snp.makeConstraints{
            $0.edges.equalTo(contentView)
        }
        
        MogakView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            //            $0.trailing.equalTo(JogakLabel)
            $0.top.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(45)
        }
        MogakStackView.snp.makeConstraints{
            $0.leading.equalTo(cellStackView.snp.leading).offset(20)
        }
        
        MogakLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(3)
        }
        
        MogakButtonView.snp.makeConstraints {
            $0.width.height.equalTo(16)
            $0.centerY.equalTo(MogakLabel)
            $0.trailing.equalToSuperview()
        }
        
        //        jogakImageView.snp.makeConstraints{
        //            $0.width.height.equalTo(20)
        //            $0.leading.equalTo(JogakStackView.snp.leading)
        //
        //        }
        
        JogakStackView.snp.makeConstraints {
            $0.leading.equalTo(cellStackView.snp.leading).inset(40)
            $0.top.equalTo(MogakStackView.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().inset(12)
        }
    
        
    }
    
    func configureMogak(with mogakData: DetailMogakData) {
        //색갈 조절 해야댐ㅇㅇ
        MogakLabel.text = mogakData.title
        
        if mogakData.color == nil{
            MogakLabel.textColor = DesignSystemColor.signature.value
            MogakLabel.backgroundColor = DesignSystemColor.signature.value.withAlphaComponent(0.1)
            
        }else{
            MogakLabel.backgroundColor = UIColor(hex: mogakData.color ?? "").withAlphaComponent(0.1)
            MogakLabel.textColor = UIColor(hex: mogakData.color ?? "")
            
        }
        
    }
    
    func configureJogak(with jogakDataArray: [JogakDetail]) {
        
        JogakStackView.arrangedSubviews.forEach { view in
            JogakStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for jogakData in jogakDataArray {
            
            let JogakLabel = UILabel() // 새로운 라벨을 생성합니다
            JogakLabel.text = jogakData.title
            JogakLabel.textColor = .black
            JogakLabel.backgroundColor = .clear
            JogakLabel.font = UIFont(name: "PretendardVariable-Medium", size: 16)
            
            let JogakimageView = UIImageView()
            JogakimageView.tintColor = UIColor(red: 0.749, green: 0.766, blue: 0.833, alpha: 1)
            JogakimageView.image = UIImage(systemName: "square")
            
            JogakimageView.snp.makeConstraints{
                $0.height.width.equalTo(20)
                
            }
            
            
            let JogakLabelStackView = UIStackView()
            JogakLabelStackView.axis = .horizontal
            JogakLabelStackView.spacing = 10
            
            JogakLabelStackView.snp.makeConstraints{
                $0.height.equalTo(20)
            }
            
            JogakLabelStackView.addArrangedSubview(JogakimageView)
            JogakLabelStackView.addArrangedSubview(JogakLabel)
            JogakStackView.addArrangedSubview(JogakLabelStackView)
            
            print(JogakLabel.text)
            
        }
        
    }
    
    //    @objc func JogakStackViewTap() {
    //        guard let jogakLabel = JogakLabel.text, !jogakLabel.isEmpty else {
    //            print("JogakLabel 텍스트가 nil이거나 비어 있습니다.")
    //            return
    //        }
    //
    //        if let currentImage = jogakImageView.image,
    //           let filledImage = UIImage(systemName: "checkmark.square.fill")?.withTintColor(DesignSystemColor.lightGreen.value, renderingMode: .alwaysOriginal) {
    //
    //            if currentImage == UIImage(systemName: "square") {
    //                jogakImageView.image = filledImage
    //                print("이미지를 선택 상태로 변경했습니다.")
    //            } else {
    //                jogakImageView.image = UIImage(systemName: "square")
    //                jogakClickClosure = nil
    //
    //                if let parentVC = parentViewController,
    //                   let index = parentVC.SelectJogaklist.firstIndex(of: jogakLabel) {
    //                    parentVC.SelectJogaklist.remove(at: index)
    //                }
    //
    //                print("이미지를 원래 상태로 변경했습니다.")
    //            }
    //
    //            jogakClickClosure?(jogakLabel)
    //            let schedulcell = ScheduleTableViewCell()
    //            if currentImage == UIImage(systemName: "square") {
    //                print("선택된 JogakLabel: \(jogakLabel)")
    //                schedulcell.cellLabel.text = jogakLabel
    //            } else {
    //                print("\(jogakLabel) 선택이 해제되었습니다.")
    //            }
    //        }
    //    }
}



