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
import Alamofire

class SelectJogakModal : UIViewController{
    
    var TableViewReload : (()->())? //tableviewreload
    //셀
    var SelectJogaklist : [String] = ["312","asd"] // 루틴으로 지정된 조각
    
    //모다라트
    var modalartList: [ModalartList] = [] ///모든 모다라트 리스트
    var nowShowModalArtNum: Int = 0
    var nowShowModalArtIndex: Int = 0
    
    
    var mogakDataCategory: [MogakCategory] = []
    
    var jogakData: [JogakDetail] = []
    var mogakData: [DetailMogakData] = []
    
    let Apinetwork =  ApiNetwork.shared
    
    //MARK: - Basic Properties
    
    private lazy var contentView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var mainLabel : UIButton = {
        let btn = UIButton()
        btn.setTitle("내 모다라트", for: .normal)
        btn.titleLabel?.font = DesignSystemFont.semibold20L140.value
        btn.setTitleColor(.black, for: .normal)
        btn.isUserInteractionEnabled = true
        btn.addTarget(self, action: #selector(tapModalart), for: .touchUpInside)
        return btn
    }()
    
    //모다라트 리스트 라벨
    lazy var listLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    private lazy var labelImage : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "chevron.down")
        image.tintColor = UIColor(hex: "#6E707B")
        image.isUserInteractionEnabled = true
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
    
    //MARK: - modalart정보를 받는 곳
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        getModalart()
    }
    
    //MARK: - UIsetting
    
    func setUI(){
        view.addSubviews(mainLabel,listLabel,labelImage,contentView)
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
        
        MogakTableView.register(MogakTableViewCell.self, forCellReuseIdentifier: "MogakTableViewCell")
        
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
        
        MogakTableView.register(MogakTableViewCell.self, forCellReuseIdentifier: "MogakTableViewCell")
        
        MogakTableView.reloadData()
        MogakTableView.dataSource = self
        MogakTableView.delegate = self
        MogakTableView.separatorStyle = .none
        MogakTableView.rowHeight = UITableView.automaticDimension
        
    }
    //MARK: - 모다라트 변경
    @objc func tapModalart(){
        setupMenu()
        print("taplabel")
    }
    
    //MARK: - 모다라트 리스트 조회
    private func getModalart(){
        Apinetwork.getModalartList{ result in
            switch result {
            case .failure(let error):
                print("\(error.localizedDescription)")
            case .success(let list):
                guard let modalartList = list else { return }
                self.modalartList = modalartList
                print("\(self.modalartList)")
                
                if modalartList.isEmpty {
                    self.mainLabel.setTitle("내 모다라트", for: .normal)
                } else {
                    guard let firstData = modalartList.first else { return }
                    self.nowShowModalArtNum = firstData.id
                    self.nowShowModalArtIndex = 0
                    self.setupMenu()
                }
            }
        }
        
        
    }
    
    //MARK: - 모다라트 리스트 보는 UImenu
    func setupMenu(){
        var menuActions: [UIAction] = []
        for modalartInfo in modalartList {
            let action = UIAction(
                title: modalartInfo.title,
                handler: { [unowned self] _ in
                    //리스트 라벨
                    self.listLabel.text = modalartInfo.title
                    //선택시 모다라트 변경
                    self.mainLabel.setTitle(modalartInfo.title, for: .normal)
                    self.getModalartDetailInfo(id: modalartInfo.id)
                    
                    //테이블 뷰 리로딩
                    self.MogakTableView.reloadData()
                }
            )
            menuActions.append(action)
        }
        
        let modalartListMenu = UIMenu(children: menuActions)
        
        //mainLabel.addInteraction(UIContextMenuInteraction(delegate: self))
        
        mainLabel.menu = modalartListMenu
        mainLabel.showsMenuAsPrimaryAction = true
    }
    
    //MARK: - 한 모다라트에 대응하는 모각 보기
    func getModalartDetailInfo(id: Int) {
        Apinetwork.getDetailModalartInfo(modalartId: id) { result in
            switch result {
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                
            case .success(let modalInfo):
                guard let modalInfo = modalInfo else { return }
                self.getDetailMogakData(id: modalInfo.id)
                print("\(modalInfo.id) 의 id인 모각")
            }
            
        }
        
    }
    
    func getDetailMogakData(id: Int) {
        Apinetwork.getDetailMogakData(modalartId: id) { result in
            switch result {
            case .success(let data):
                if let mogakDataArray = data?.result?.mogaks{
                    self.mogakData = mogakDataArray     //모각 데이터 받아옴
                    for mogakData in mogakDataArray {
                        print(mogakData)
                    }
                    self.MogakTableView.reloadData()
                    
                } else {
                    print("모다라트에 해당하는 모각 데이터가 없습니다.")
                }
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            }
        }
    }
//MARK: - 한 모각에 대응하는 조각보기
    func getDetailJogakData(id : Int){
        Apinetwork.getAllMogakDetailJogaks(mogakId: id){result in
            switch result{
            case.success(let data):
                if let jogakDetailArray = data {
                    self.jogakData = jogakDetailArray
                    
                } else {
                    print("JogakDetailArray나 result가 nil입니다.")
                }
                
            case.failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            }
        }
    }
    
    
}

extension SelectJogakModal: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mogakData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MogakTableViewCell", for: indexPath)
        
        if let mogakCell = cell as? MogakTableViewCell {
            
            let mogakDataItem = mogakData[indexPath.row]
            mogakCell.configureMogak(with: mogakDataItem)
            
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
        
        
        if let cell = tableView.cellForRow(at: indexPath) as? MogakTableViewCell {
            
            let jogakDataItem = jogakData //조각 호출
            cell.configureJogak(with: jogakDataItem)
            
            cell.JogakStackView.isHidden = !cell.JogakStackView.isHidden
            
            
            if cell.JogakStackView.isHidden {
                cell.MogakButtonView.image = UIImage(systemName: "chevron.up")
                
                
            } else {
                cell.MogakButtonView.image = UIImage(systemName: "chevron.down")
                
                
                let selectedMogakData = mogakData[indexPath.row]
                print("Selected Mogak Data: \(selectedMogakData)")
                
                let mogakId = selectedMogakData.mogakId
                getDetailJogakData(id: mogakId)
            }
            
            //print("상태 \(cell.JogakLabel.isHidden)")
            
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

//extension SelectJogakModal : UIContextMenuInteractionDelegate{
//
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(
//                    identifier: nil,
//                    previewProvider: nil,
//                    actionProvider: { _ in
//                        return self.modalartListMenu
//                    }
//                )
//
//    }
//
//
//}























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

