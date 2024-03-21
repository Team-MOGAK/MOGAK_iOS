//
//  SelectModalartTableView.swift
//  MOGAK
//
//  Created by 안세훈 on 3/16/24.
//

import Foundation
import UIKit
import SnapKit
import Then
import Alamofire

class SelectModalartTableView : UIViewController{
    
    
//MARK: - 모다라트 정보

    var modalartList: [ScheduleModalartList] = []
    
    let Apinetwork =  ApiNetwork.shared
    
//MARK: - 기본 프로퍼티

    
    private lazy var mainLabel : UIButton = {
        let btn = UIButton()
        btn.setTitle("내 모다라트", for: .normal)
        btn.titleLabel?.font = DesignSystemFont.semibold20L140.value
        btn.setTitleColor(.black, for: .normal)
        btn.isUserInteractionEnabled = true
        //btn.addTarget(self, action: #selector(tapModalart), for: .touchUpInside)
        return btn
    }()
    
    lazy var ModalartTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private lazy var contentView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
//MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        SetUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getModalart()
    }
    
//MARK: - func

    func SetUI(){
        view.addSubviews(mainLabel,contentView)
        contentView.addSubviews(ModalartTableView)
        
        mainLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(36)
        }
        
        contentView.snp.makeConstraints{
            $0.top.equalTo(mainLabel.snp.bottom).offset(24)
            $0.leading.trailing.bottom.equalToSuperview()
            
        }
    }
    
    func getModalart() {
        Apinetwork.getModalartList { result in
            switch result {
            case .failure(let error):
                print("\(error.localizedDescription)")
            case .success(let list):
                print(list as Any)
                
            }
        }
    }
    
    
}


extension SelectModalartTableView : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectModalartTableViewCell", for: indexPath) as? SelectModalartTableViewCell else {
            
            return UITableViewCell()
        }
        
        return cell
    }
    
}

class SelectModalartTableViewCell : UITableViewCell{
    
    
    private lazy var ModalartLabel : CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 12, bottom: 12, left: 20, right: 20)
        label.font = DesignSystemFont.medium16L150.value
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var ModalartView : UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var ModalartStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ModalartView])
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.backgroundColor = .white
        return stackView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutModalart()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func layoutModalart(){
//        contentView.addSubviews(MogakStackView,MogakButtonView)
//        MogakView.addSubview(MogakLabel)
    }
}

//Preview code
#if DEBUG
import SwiftUI
struct SelectModalartVCRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        SelectModalartTableView()
    }
}
@available(iOS 13.0, *)
struct SelectModalartVCRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            if #available(iOS 14.0, *) {
                SelectModalartVCRepresentable()
                    .ignoresSafeArea()
                    .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                    .previewDevice(PreviewDevice(rawValue: "iPhone se3"))
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
} #endif
