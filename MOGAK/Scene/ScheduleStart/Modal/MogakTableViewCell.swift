//
//  MogakTableViewCell.swift
//  MOGAK
//
//  Created by 안세훈 on 11/6/23.
//

import Foundation
import SnapKit
import Then

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
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    lazy var JogakLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    var jogakImageView : UIImageView = {
        let image = UIImageView()
        image.tintColor = UIColor(red: 0.749, green: 0.766, blue: 0.833, alpha: 1)
        return image
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
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var JogakStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [jogakImageView,JogakLabel])
        stackView.isHidden = true
        stackView.axis = .horizontal
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins.left = 40
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        
        stackView.isUserInteractionEnabled = true
        
        let tapjogakStackView = UITapGestureRecognizer(target: self, action: #selector(JogakStackViewTap))
        stackView.addGestureRecognizer(tapjogakStackView)
        
        return stackView
    }()
    
    private lazy var cellStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [MogakStackView,JogakStackView])
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.distribution = .fillEqually
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
        
        contentView.addSubviews(MogakView,MogakButtonView,cellStackView)
        MogakView.addSubview(MogakLabel)
        
        
        cellStackView.snp.makeConstraints{
            $0.edges.equalTo(contentView)
        }
        
        MogakStackView.snp.makeConstraints{
            $0.top.equalTo(cellStackView)
            
        }
        
        MogakLabel.snp.makeConstraints {
            $0.centerY.equalTo(MogakStackView)
            $0.leading.trailing.equalTo(MogakView)
            $0.top.bottom.equalTo(MogakView)
            
        }
        
        MogakView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        MogakButtonView.snp.makeConstraints {
            $0.width.height.equalTo(16)
            $0.centerY.equalTo(MogakLabel)
            $0.trailing.equalTo(MogakStackView).inset(20)
        }
        
        jogakImageView.snp.makeConstraints{
            $0.width.height.equalTo(20)
            
        }
        JogakLabel.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.centerY.equalTo(JogakStackView)
        }
        
    }
    
    func configure(with mogak: SelectJogakModal.Mogak) {
        MogakLabel.text = mogak.mogaktitle
        MogakLabel.textColor = mogak.mogaktitleColor
        JogakLabel.text = mogak.jogak
        MogakView.backgroundColor = mogak.ViewColor
        jogakImageView.image = UIImage(systemName: "square")
    }
    
    @objc func JogakStackViewTap() {
        guard let jogakLabel = JogakLabel.text, !jogakLabel.isEmpty else {
            print("JogakLabel 텍스트가 nil이거나 비어 있습니다.")
            return
        }

        if let currentImage = jogakImageView.image,
           let filledImage = UIImage(systemName: "checkmark.square.fill")?.withTintColor(DesignSystemColor.lightGreen.value, renderingMode: .alwaysOriginal) {

            if currentImage == UIImage(systemName: "square") {
                jogakImageView.image = filledImage
                print("이미지를 선택 상태로 변경했습니다.")
            } else {
                jogakImageView.image = UIImage(systemName: "square")
                jogakClickClosure = nil

                if let parentVC = parentViewController,
                   let index = parentVC.SelectJogaklist.firstIndex(of: jogakLabel) {
                    parentVC.SelectJogaklist.remove(at: index)
                }

                print("이미지를 원래 상태로 변경했습니다.")
            }

            jogakClickClosure?(jogakLabel)
            let schedulcell = ScheduleTableViewCell()
            if currentImage == UIImage(systemName: "square") {
                print("선택된 JogakLabel: \(jogakLabel)")
                schedulcell.cellLabel.text = jogakLabel
            } else {
                print("\(jogakLabel) 선택이 해제되었습니다.")
            }
        }
    }
}



