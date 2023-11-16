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
    
    
    private lazy var MogakLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        return label
    }()
    
    private lazy var MogakView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    lazy var JogakLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.isHidden = true
        label.isUserInteractionEnabled = true
        
        let tapJogaklabel = UITapGestureRecognizer(target: self, action: #selector(JogakLabelTap))
        label.addGestureRecognizer(tapJogaklabel)
        return label
    }()
    
    let jogakImageView : UIImageView = {
        let image = UIImageView()
        image.isHidden = true
        return image
        
    }()
    
    let MogakButtonView : UIImageView = {
        let MogakButton = UIImageView()
        MogakButton.image = UIImage(systemName: "chevron.up")
        MogakButton.tintColor = DesignSystemColor.icongray.value
        return MogakButton
    }()
    
    
    //MARK: - StackViews
 
    private lazy var MogakStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [MogakLabel,MogakView,MogakButtonView])
        stackView.axis = .horizontal
        return stackView
    }()
    
    lazy var jogakStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [jogakImageView,JogakLabel])
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var cellStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [MogakStackView,jogakStackView])
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
    
    //MARK: - SetUI
    
    private func setUI() {
        
        contentView.addSubviews(cellStackView)
        MogakView.addSubview(MogakLabel) //고정
        
        cellStackView.snp.makeConstraints{
            $0.edges.equalTo(contentView)
        }
//        MogakStackView.snp.makeConstraints{
//            $0.top.leading.trailing.equalTo(cellStackView)
//            $0.bottom.equalTo(jogakStackView.snp.top).offset(16)
//        }
        
//        jogakStackView.snp.makeConstraints{
//            $0.top.equalTo(MogakStackView.snp.bottom).offset(16)
//            $0.leading.trailing.equalToSuperview()
//            $0.bottom.equalToSuperview().offset(24)
//        }
        
//        MogakLabel.snp.makeConstraints {
//            $0.leading.equalToSuperview().offset(40)
//            $0.top.equalToSuperview().offset(12)
//        }
//        
//        MogakView.snp.makeConstraints {
//            $0.leading.equalTo(MogakLabel).inset(-20)
//            $0.top.equalTo(MogakLabel).inset(-12)
//            $0.trailing.equalTo(MogakLabel).inset(-20)
//            $0.bottom.equalTo(MogakLabel).inset(-12)
//        }
//        
//        MogakButtonView.snp.makeConstraints {
//            $0.width.height.equalTo(16)
//            $0.centerY.equalTo(MogakLabel)
//            $0.trailing.equalToSuperview().inset(20)
//        }
        
//        jogakImageView.snp.makeConstraints{
//            $0.width.height.equalTo(20)
//            $0.top.equalTo(MogakStackView.snp.bottom).offset(38)
//            $0.leading.equalTo(cellStackView).offset(40)
//            $0.centerY.equalTo(JogakLabel)
//            
//        }
//        
//        JogakLabel.snp.makeConstraints {
//            $0.centerY.equalTo(jogakImageView)
//            $0.leading.equalTo(jogakImageView.snp.trailing).offset(12)
//        }
        
        
        
    }
    
    
    func configure(with mogak: SelectJogakModal.Mogak) {
        MogakLabel.text = mogak.mogaktitle
        MogakLabel.textColor = mogak.mogaktitleColor
        JogakLabel.text = mogak.jogak
        MogakView.backgroundColor = mogak.ViewColor
        jogakImageView.image = mogak.jogakimage
    }
    
    @objc func JogakLabelTap(){
        print("JogakLabel is tapped by You!!!!!!!!!!!!")
    }
    
}

