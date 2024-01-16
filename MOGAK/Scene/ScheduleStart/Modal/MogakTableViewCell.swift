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
    
    //MARK: - Mogak
    
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
        return stackView
    }()
    
    lazy var JogakStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isHidden = true
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var cellStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [MogakStackView,JogakStackView])
        stackView.axis = .vertical
        stackView.spacing = 10
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
            $0.top.bottom.equalToSuperview().inset(12)
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
            MogakView.backgroundColor = .lightGray
        }else{
            MogakLabel.backgroundColor = UIColor(hex: mogakData.color ?? "").withAlphaComponent(0.1)
            MogakLabel.textColor = UIColor(hex: mogakData.color ?? "")
            
        }
        
    }    
//MARK: - Jogak
    
    var jogakLabels: [UILabel] = []
    var jogakImageViews: [UIImageView] = []
    var jogakLabelStackViews: [UIStackView] = []
    
//MARK: - Jogak
    func configureJogak(with jogakDataArray: [JogakDetail]) {
        JogakStackView.arrangedSubviews.forEach { view in
            JogakStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }


        for jogakData in jogakDataArray {
            
            jogakLabels = []
            jogakImageViews = []
            jogakLabelStackViews = []
            
            let jogakLabel = UILabel()
            jogakLabel.text = jogakData.title
            jogakLabel.textColor = .black
            jogakLabel.backgroundColor = .clear
            jogakLabel.font = UIFont(name: "PretendardVariable-Medium", size: 16)

            let jogakimageView = UIImageView()
            jogakimageView.tintColor = UIColor(red: 0.749, green: 0.766, blue: 0.833, alpha: 1)

            if jogakData.isRoutine == false {
                jogakimageView.image = UIImage(systemName: "square")
            } else {
                jogakimageView.image = UIImage(systemName: "checkmark.square.fill")?.withTintColor(DesignSystemColor.lightGreen.value, renderingMode: .alwaysOriginal)
            }

            jogakimageView.snp.makeConstraints {
                $0.height.width.equalTo(20)
            }

            let jogakLabelStackView = UIStackView()
            jogakLabelStackView.axis = .horizontal
            jogakLabelStackView.spacing = 10

            // let tapjogakStackView = UITapGestureRecognizer(target: self, action: #selector(JogakStackViewTap))

            if jogakData.isRoutine == false {
                // jogakLabelStackView.addGestureRecognizer(tapjogakStackView)
            } else {
                print("isRoutine이 true라서 터치안댐ㅇㅇ")
            }

            jogakLabelStackView.addArrangedSubview(jogakimageView)
            jogakLabelStackView.addArrangedSubview(jogakLabel)

            JogakStackView.addArrangedSubview(jogakLabelStackView)

            jogakLabels.append(jogakLabel)
            jogakImageViews.append(jogakimageView)
            jogakLabelStackViews.append(jogakLabelStackView)
            
            print(jogakLabels)
            print(jogakData.jogakID)
            //print(jogakData.title)
        }
    }
    
//    @objc func JogakStackViewTap(_ sender: UITapGestureRecognizer) {
//        if let index = jogakLabelStackViews.firstIndex(of: sender.view as! UIStackView) {
//            let jogakLabel = jogakLabels[index]
//            let jogakImageView = jogakImageViews[index]
//            
//            print("스택뷰 터치댐ㅇㅇ")
//            guard let text = jogakLabel.text, !text.isEmpty else {
//                print("JogakLabel 텍스트가 nil이거나 비어 있습니다.")
//                return
//            }
//            
//            if let currentImage = jogakImageView.image,
//               let filledImage = UIImage(systemName: "checkmark.square.fill")?.withTintColor(DesignSystemColor.lightGreen.value, renderingMode: .alwaysOriginal) {
//                
//                if currentImage == UIImage(systemName: "square") {
//                    jogakImageView.image = filledImage
//                    print("이미지를 선택 상태로 변경했습니다.")
//                } else {
//                    jogakImageView.image = UIImage(systemName: "square")
//                    jogakClickClosure = nil
//                    
//                    if let parentVC = parentViewController,
//                       let index = parentVC.SelectJogaklist.firstIndex(of: text) {
//                        parentVC.SelectJogaklist.remove(at: index)
//                    }
//                    
//                    print("이미지를 원래 상태로 변경했습니다.")
//                }
//                
//                jogakClickClosure?(text)
//                let schedulcell = ScheduleTableViewCell()
//                if currentImage == UIImage(systemName: "square") {
//                    print("선택된 JogakLabel: \(text)")
//                    schedulcell.cellLabel.text = text
//                } else {
//                    print("\(text) 선택이 해제되었습니다.")
//                }
//            }
//        }
//    }
//    
    
}



