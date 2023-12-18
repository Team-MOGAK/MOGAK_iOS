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

class SelectJogakModal : UIViewController{
    
    let currentDate = Date()
    var TableViewReload : (()->())? //tableviewreload
    var SelectJogaklist : [String] = ["312","asd"]
    
    //MARK: - Basic Properties
    
    private lazy var contentView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var mainLabel : UILabel = {
        let label = UILabel()
        label.text = "내 모다라트"
        label.textColor = .black
        label.font = DesignSystemFont.semibold20L140.value
        label.isUserInteractionEnabled = true
        
        let mainLabeltap = UITapGestureRecognizer(target: self, action: #selector(tapLabel))
        label.addGestureRecognizer(mainLabeltap)
        return label
    }()
    
    private lazy var labelImage : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "chevron.down")
        image.tintColor = UIColor(hex: "#6E707B")
        image.isUserInteractionEnabled = true
        
        let imagetap = UITapGestureRecognizer(target: self, action: #selector(tapLabel))
        image.addGestureRecognizer(imagetap)
        return image
    }()
    
    private lazy var addButton : UIButton = {
        let button = UIButton()
        button.setTitle("추가하기", for: .normal)
        button.titleLabel?.font = DesignSystemFont.semibold18L100.value
        button.backgroundColor = DesignSystemColor.signature.value
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(addJogak), for: .touchUpInside)
        return button
    }()
    
    //클로저는 보내는 VC에서 설정 : String에서 보내고 받는쪽은 Void
    
    //MARK: - Mogak 구조체
    struct Mogak {
        var mogaktitle: String
        var mogaktitleColor : UIColor
        var jogak: String
        var ViewColor: UIColor
        var jogakimage : UIImage
        var jogakDate: Date
    }
    
    //MARK: - modalart정보를 받는 곳
    
    var mogakList: [Mogak] = [
        Mogak(mogaktitle: "10키로 감량!", mogaktitleColor: DesignSystemColor.mint.value, jogak: "공복 유산소", ViewColor: DesignSystemColor.brightmint.value, jogakimage:UIImage(systemName: "square")!, jogakDate: Date()),
        
        Mogak(mogaktitle: "자격증 4개따기", mogaktitleColor: DesignSystemColor.orange.value, jogak: "ㅁㅇㄴ", ViewColor: DesignSystemColor.yellow.value, jogakimage:UIImage(systemName: "square")!, jogakDate: Date()),
        
        Mogak(mogaktitle: "시험 합격", mogaktitleColor: DesignSystemColor.ruby.value, jogak: "이건 세번쩨 조각", ViewColor: DesignSystemColor.pink.value, jogakimage:UIImage(systemName: "square")!, jogakDate: Date()),
        
        Mogak(mogaktitle: "공모전에서 수상하기", mogaktitleColor: DesignSystemColor.signature.value, jogak: "ㅁㄴ", ViewColor: DesignSystemColor.lavender.value,jogakimage:UIImage(systemName: "square")!, jogakDate: Date())
    ]
    
    lazy var MogakTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        return table
    }()
    
    let mogaktableviewcell = MogakTableViewCell()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        tableSetUI()
    }
    
    //MARK: - UIsetting
    
    func setUI(){
        view.addSubviews(mainLabel,labelImage,contentView)
        contentView.addSubviews(MogakTableView,addButton)
        
        contentView.snp.makeConstraints{
            $0.top.equalTo(mainLabel.snp.bottom).offset(24)
            $0.leading.trailing.bottom.equalToSuperview()
            
        }
        mainLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(36)
        }
        
        MogakTableView.snp.makeConstraints{
            $0.top.leading.trailing.equalTo(contentView)
            $0.bottom.equalToSuperview()
        }
        
        MogakTableView.register(MogakTableViewCell.self, forCellReuseIdentifier: "MogakCell")
        
        addButton.snp.makeConstraints{
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
            
        }
        labelImage.snp.makeConstraints{
            $0.width.height.equalTo(16)
            $0.centerY.equalTo(mainLabel)
            $0.leading.equalTo(mainLabel.snp.trailing).offset(12)
        }
        
    }
    
    func tableSetUI(){
        MogakTableView.snp.makeConstraints{
            $0.edges.equalTo(contentView)
        }
        
        MogakTableView.register(MogakTableViewCell.self, forCellReuseIdentifier: "MogakCell")
        
        MogakTableView.reloadData()
        MogakTableView.dataSource = self
        MogakTableView.delegate = self
        MogakTableView.separatorStyle = .none
        MogakTableView.rowHeight = UITableView.automaticDimension
        
    }
    //MARK: - 모다라트 변경
    
    @objc func tapLabel(){
        if labelImage.image == UIImage(systemName: "chevron.down"){
            labelImage.image = UIImage(systemName: "chevron.up")
            print("up")
        }else{
            labelImage.image = UIImage(systemName: "chevron.down")
            print("down")
        }
        
        print("taplabel")
    }
}

extension SelectJogakModal: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mogakList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MogakCell", for: indexPath)
        
        if let mogakCell = cell as? MogakTableViewCell {
            let mogak = mogakList[indexPath.row]
            mogakCell.configure(with: mogak)
            
            mogakCell.jogakClickClosure = { [weak self] jogakLabel in
                        
                print("JogakLabel: \(jogakLabel) 클릭됨!")
                        // self?.SelectJogaklist에 접근 가능
                self?.handleJogakSelection(jogakLabel)
            }

        }
        
        return cell
    }
    
    func handleJogakSelection(_ jogakLabel: String) {
        
        print("JogakLabel: \(jogakLabel) 추가됨!")
        
        self.SelectJogaklist.append(jogakLabel)
        
        print("SelectJogaklist에 추가: \(self.SelectJogaklist)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    //MARK: - 셀 클릭시 반응
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? MogakTableViewCell {//
            cell.JogakStackView.isHidden = !cell.JogakStackView.isHidden
            
            if cell.JogakStackView.isHidden {
                cell.MogakButtonView.image = UIImage(systemName: "chevron.up")
            } else {
                cell.MogakButtonView.image = UIImage(systemName: "chevron.down")
            }
                  
            print("상태 \(cell.JogakLabel.isHidden)")
            
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    //MARK: - 추가하기 버튼 클릭시
    @objc func addJogak(){
        dismiss(animated: true){ [weak self] in
            print("테이블 뷰 리로드 클로저 ㅇㅇ")
            
            self?.TableViewReload?()
            print("추가 후의 SelectJogaklist: \(self?.SelectJogaklist ?? [])")
            print(self?.SelectJogaklist.count as Any)
            self?.MogakTableView.reloadData()
        }
        
    }
    
}


extension Date {
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
}
























//Preview code
#if DEBUG
import SwiftUI
struct abBarViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        SelectJogakModal()
    }
}
@available(iOS 13.0, *)
struct abBarViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            if #available(iOS 14.0, *) {
                abBarViewControllerRepresentable()
                    .ignoresSafeArea()
                    .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                    .previewDevice(PreviewDevice(rawValue: "iPhone se3"))
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
} #endif

