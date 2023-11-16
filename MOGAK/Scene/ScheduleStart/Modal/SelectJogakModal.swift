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
    
    //MARK: - Basic Properties
    
    private lazy var contentView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var mainLabel : UILabel = {
        let label = UILabel()
        label.text = "조각 선택"
        label.textColor = .black
        label.font = DesignSystemFont.semibold18L100.value
        return label
    }()
    
    var configureClosure: ((String) -> Void)? //클로저는 보내는 VC에서 설정 : String에서 보내고 받는쪽은 Void
    
    //MARK: - Mogak 구조체
    struct Mogak {
        var mogaktitle: String
        var mogaktitleColor : UIColor
        var jogak: String
        var ViewColor: UIColor
        var jogakimage : UIImage
        var jogakDate: Date
    }
    //MARK: - 정보를 받는 곳
    
    var mogakList: [Mogak] = [
        Mogak(mogaktitle: "10키로 감량!", mogaktitleColor: DesignSystemColor.mint.value, jogak: "공복 유산소", ViewColor: DesignSystemColor.brightmint.value, jogakimage:UIImage(named: "emptySquareCheckmark")!, jogakDate: Date()),
        
        Mogak(mogaktitle: "자격증 4개따기", mogaktitleColor: DesignSystemColor.orange.value, jogak: "ㅁㅇㄴ", ViewColor: DesignSystemColor.yellow.value, jogakimage: UIImage(named: "emptySquareCheckmark")!, jogakDate: Date()),
        
        Mogak(mogaktitle: "시험 합격", mogaktitleColor: DesignSystemColor.ruby.value, jogak: "이건 세번쩨 조각", ViewColor: DesignSystemColor.pink.value, jogakimage: UIImage(named: "emptySquareCheckmark")!, jogakDate: Date()),
        
        Mogak(mogaktitle: "공모전에서 수상하기", mogaktitleColor: DesignSystemColor.signature.value, jogak: "ㅁㄴ", ViewColor: DesignSystemColor.lavender.value, jogakimage: UIImage(named: "emptySquareCheckmark")!, jogakDate: Date())
    ]
    
    lazy var MogakTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.dataSource = self
        table.delegate = self
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
        view.addSubviews(mainLabel,contentView)
        contentView.addSubviews(MogakTableView)
        
        contentView.snp.makeConstraints{
            $0.top.equalTo(mainLabel.snp.bottom).offset(24)
            $0.leading.trailing.bottom.equalToSuperview()
            //$0.height.equalTo(1200)
            
        }
        mainLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(36)
        }
        
        MogakTableView.snp.makeConstraints{
            $0.edges.equalTo(contentView)
        }
        
        MogakTableView.register(MogakTableViewCell.self, forCellReuseIdentifier: "MogakCell")
        
    }
    
    func tableSetUI(){
        MogakTableView.snp.makeConstraints{
            $0.edges.equalTo(contentView)
        }
        
        MogakTableView.register(MogakTableViewCell.self, forCellReuseIdentifier: "MogakCell")
        
        MogakTableView.reloadData()
        MogakTableView.separatorStyle = .none
        MogakTableView.rowHeight = UITableView.automaticDimension
        
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
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    
    
    //MARK: - 셀 클릭시 반응
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? MogakTableViewCell {
            cell.JogakLabel.isHidden = !cell.JogakLabel.isHidden
            cell.jogakImageView.isHidden = !cell.jogakImageView.isHidden
            
            if cell.JogakLabel.isHidden {
                cell.MogakButtonView.image = UIImage(systemName: "chevron.up")
            } else {
                cell.MogakButtonView.image = UIImage(systemName: "chevron.down")
            }
            
            print("상태 \(cell.JogakLabel.isHidden)")
            
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    //    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    //        tableView.beginUpdates()
    //        tableView.endUpdates()
    //    }
    
    
}

extension Date {
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
}

























////Preview code
//#if DEBUG
//import SwiftUI
//struct SelectJogakModalRepresentable: UIViewControllerRepresentable {
//
//    func updateUIViewController(_ uiView: UIViewController,context: Context) {
//        // leave this empty
//    }
//    @available(iOS 13.0.0, *)
//    func makeUIViewController(context: Context) -> UIViewController{
//        SelectJogakModal()
//    }
//}
//@available(iOS 13.0, *)
//struct SelectJogakModalRepresentable_PreviewProvider: PreviewProvider {
//    static var previews: some View {
//        Group {
//            if #available(iOS 14.0, *) {
//                SelectJogakModalRepresentable()
//                    .ignoresSafeArea()
//                    .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
//                    .previewDevice(PreviewDevice(rawValue: "iPhone 15pro"))
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//
//    }
//} #endif

