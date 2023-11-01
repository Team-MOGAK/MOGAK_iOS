//
//  SelectJogakModal.swift
//  MOGAK
//
//  Created by 안세훈 on 10/30/23.
//

import Foundation
import UIKit
import SnapKit
import Then

class SelectJogakModal : UIViewController, UIScrollViewDelegate{
//MARK: - Properties
    
    private lazy var modalScrollView : UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.backgroundColor = .white
        scrollview.isScrollEnabled = true
        return scrollview
    }()
    
    private lazy var contentView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var mainLabel : UILabel = {
        let label = UILabel()
        label.text = "조각 선택"
        label.textColor = .black
        label.font = DesignSystemFont.semibold18L100.value
        return label
    }()
//MARK: - 모각 1
    
    private lazy var mogakView1 : UIView = {
        let view1 = UIView()
        view1.layer.cornerRadius = 8
        view1.backgroundColor = DesignSystemColor.brightmint.value
        return view1
    }()
    
    private lazy var mogakLabel1 : UILabel = {
        let label = UILabel()
        label.text = "10키로 감량!"
        label.textColor = DesignSystemColor.mint.value
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        return label
    }()
    
    private lazy var mogakButton1 : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        button.tintColor = DesignSystemColor.icongray.value
        button.addTarget(self, action: #selector(mogakbtn1cliecked), for: .touchUpInside)
        return button
    }()

    
//MARK: - 모각2
    
    private lazy var mogakView2 : UIView = {
        let view2 = UIView()
        view2.layer.cornerRadius = 8
        view2.backgroundColor = DesignSystemColor.yellow.value
        return view2
    }()
    
    private lazy var mogakLabel2 : UILabel = {
        let label = UILabel()
        label.text = "자격증 4개따기"
        label.textColor = DesignSystemColor.orange.value
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        return label
    }()
    
//MARK: - 모각3
    
    private lazy var mogakView3 : UIView = {
        let view3 = UIView()
        view3.layer.cornerRadius = 8
        view3.backgroundColor = DesignSystemColor.pink.value
        return view3
    }()
    
    private lazy var mogakLabel3 : UILabel = {
        let label = UILabel()
        label.text = "시험 합격"
        label.textColor = DesignSystemColor.ruby.value
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        return label
    }()
    
//MARK: - 모각4
    
    private lazy var mogakView4 : UIView = {
        let view4 = UIView()
        view4.layer.cornerRadius = 8
        view4.backgroundColor = DesignSystemColor.lavender.value
        return view4
    }()
    
    private lazy var mogakLabel4 : UILabel = {
        let label = UILabel()
        label.text = "공모전에서 수상하기"
        label.textColor = DesignSystemColor.signature.value
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        return label
    }()
    
//MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        self.modalScrollView.delegate = self
        setUI()
    }
    
//MARK: - button method
    @objc func mogakbtn1cliecked(){

        if let currentImage = mogakButton1.currentImage, currentImage == UIImage(systemName: "chevron.up") {
                mogakButton1.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                print("if")
            } else {
                mogakButton1.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                print("else")
            }
            
        print("mogakbtn1clicked")
    }

    //MARK: - UIsetting

    func setUI(){
        view.addSubview(modalScrollView)
        modalScrollView.addSubview(contentView)
        contentView.addSubviews(mainLabel,mogakView1,mogakLabel1,mogakButton1,mogakView2,mogakLabel2,mogakView3,mogakLabel3,mogakView4,mogakLabel4)
        
        modalScrollView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints{
            $0.edges.width.equalTo(modalScrollView)
            $0.height.equalTo(1200)
            
        }
        
        mainLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(36)
        }
        
        mogakLabel1.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(40)
            $0.top.equalTo(mainLabel.snp.bottom).offset(36)
        }
        mogakView1.snp.makeConstraints{
            $0.leading.equalTo(mogakLabel1).offset(-20)
            $0.trailing.equalTo(mogakLabel1).offset(20)
            $0.top.equalTo(mogakLabel1).offset(-12)
            $0.bottom.equalTo(mogakLabel1).offset(12)
        }
        mogakButton1.snp.makeConstraints{
            $0.centerY.equalTo(mogakLabel1)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        mogakLabel2.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(40)
            $0.top.equalTo(mogakView1.snp.bottom).offset(36)
        }
        mogakView2.snp.makeConstraints{
            $0.leading.equalTo(mogakLabel2).offset(-20)
            $0.trailing.equalTo(mogakLabel2).offset(20)
            $0.top.equalTo(mogakLabel2).offset(-12)
            $0.bottom.equalTo(mogakLabel2).offset(12)
        }
        
        mogakLabel3.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(40)
            $0.top.equalTo(mogakView2.snp.bottom).offset(36)
        }
        mogakView3.snp.makeConstraints{
            $0.leading.equalTo(mogakLabel3).offset(-20)
            $0.trailing.equalTo(mogakLabel3).offset(20)
            $0.top.equalTo(mogakLabel3).offset(-12)
            $0.bottom.equalTo(mogakLabel3).offset(12)
        }
        
        mogakLabel4.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(40)
            $0.top.equalTo(mogakView3.snp.bottom).offset(36)
        }
        mogakView4.snp.makeConstraints{
            $0.leading.equalTo(mogakLabel4).offset(-20)
            $0.trailing.equalTo(mogakLabel4).offset(20)
            $0.top.equalTo(mogakLabel4).offset(-12)
            $0.bottom.equalTo(mogakLabel4).offset(12)
        }
        
    }
}
    
    //Preview code
#if DEBUG
    import SwiftUI
    struct SelectJogakModalRepresentable: UIViewControllerRepresentable {
        
        func updateUIViewController(_ uiView: UIViewController,context: Context) {
            // leave this empty
        }
        @available(iOS 13.0.0, *)
        func makeUIViewController(context: Context) -> UIViewController{
            SelectJogakModal()
        }
    }
    @available(iOS 13.0, *)
    struct SelectJogakModalRepresentable_PreviewProvider: PreviewProvider {
        static var previews: some View {
            Group {
                if #available(iOS 14.0, *) {
                    SelectJogakModalRepresentable()
                        .ignoresSafeArea()
                        .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                        .previewDevice(PreviewDevice(rawValue: "iPhone 15pro"))
                } else {
                    // Fallback on earlier versions
                }
            }
            
        }
    } #endif

