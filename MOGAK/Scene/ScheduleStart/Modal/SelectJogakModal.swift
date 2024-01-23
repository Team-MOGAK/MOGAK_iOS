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
import ExpyTableView

class SelectJogakModal : UIViewController{
    
    var TableViewReload : (()->())? //tableviewreload
    //셀
    var SelectJogaklist : [String] = [] // 루틴으로 지정된 조각
    
    //모다라트
    var modalartList: [ScheduleModalartList] = [] ///모든 모다라트 리스트
    var modalartTitles: [String] = []
    
    var nowShowModalArtNum: Int = 0
    var nowShowModalArtIndex: Int = 0
    
    
    var mogakDataCategory: [ScheduleMogakCategory] = []
    
    var jogakData: [JogakDetail] = []
    var mogakData: [ScheduleDetailMogakData] = []
    
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
    
    lazy var MogakTableView: ExpyTableView = {
        let tableView = ExpyTableView()
        return tableView
    }()
    
    
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
        
        addButton.snp.makeConstraints{
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
            
        }
        MogakTableView.snp.makeConstraints{
            $0.top.leading.trailing.equalTo(contentView)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(58)
        }
        
        labelImage.snp.makeConstraints{
            $0.width.height.equalTo(16)
            $0.centerY.equalTo(mainLabel)
            $0.leading.equalTo(mainLabel.snp.trailing).offset(12)
        }
        
    }
    //MARK: - tableView properties
    struct MogakJogak{
        var mogaktitle = String()
        var jogaktitle = [String]()
    }
    
    var tableViewData = [MogakJogak]()
    //MARK: - tableView UI
    
    func tableSetUI() {
        MogakTableView.snp.makeConstraints{
            $0.edges.equalTo(contentView)
        }
        
        MogakTableView.register(MogakTableViewCell.self, forCellReuseIdentifier: "MogakTableViewCell")
        
        MogakTableView.reloadData()
        MogakTableView.dataSource = self
        MogakTableView.delegate = self
        MogakTableView.separatorStyle = .none
        
        tableViewData = [MogakJogak(mogaktitle: "", jogaktitle: [""]),
                         MogakJogak(mogaktitle: "", jogaktitle: [""]),
                         MogakJogak(mogaktitle: "", jogaktitle: [""]),
                         MogakJogak(mogaktitle: "", jogaktitle: [""]),
                         MogakJogak(mogaktitle: "", jogaktitle: [""]),
                         MogakJogak(mogaktitle: "", jogaktitle: [""]),
                         MogakJogak(mogaktitle: "", jogaktitle: [""]),
                         MogakJogak(mogaktitle: "", jogaktitle: [""])]
    }
    //MARK: - 모다라트 변경
    @objc func tapModalart(){
        setupMenu()
    }
    
    //MARK: - 모다라트 리스트 조회
    func getModalart() {
        Apinetwork.getModalartList { result in
            switch result {
            case .failure(let error):
                print("\(error.localizedDescription)")
            case .success(let list):
                guard let modalartList = list else { return }
                
                self.modalartList = modalartList.map { modalart in
                    return ScheduleModalartList(id: modalart.id, title: modalart.title)
                }
                
                self.modalartTitles = self.modalartList.map { $0.title }
                
                
                if self.modalartList.isEmpty {
                    self.mainLabel.setTitle("내 모다라트", for: .normal)
                } else {
                    guard let firstData = self.modalartList.first else { return }
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
                    //열린 섹션 닫기
                    for section in 0..<self.MogakTableView.numberOfSections {
                        self.MogakTableView.collapse(section)
                    }
                    
                    
                    //테이블 뷰 리로딩
                    self.MogakTableView.reloadData()
                    
                }
            )
            menuActions.append(action)
            
        }
        let modalartListMenu = UIMenu(children: menuActions)
        
        mainLabel.menu = modalartListMenu
        mainLabel.showsMenuAsPrimaryAction = true
    }
    
    //MARK: - 모다라트 정보
    func getModalartDetailInfo(id: Int) {
        Apinetwork.getDetailModalartInfo(modalartId: id) { result in
            switch result {
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
                
            case .success(let modalInfo):
                guard let modalInfo = modalInfo else { return }
                self.getDetailMogakData(id: modalInfo.id)
                print("\(modalInfo.id) 의 id인 모다라트")
                
            }
            
        }
        
    }
    //MARK: - 모각 정보
    func getDetailMogakData(id: Int) {
        Apinetwork.getDetailMogakData(modalartId: id) { result in
            switch result {
            case .success(let data):
                if let mogakDataArray = data?.result?.mogaks{
                    self.mogakData = mogakDataArray     //모각 데이터 받아옴
                    //데이터 초기화하는 코드 추가해야함
                    self.MogakTableView.reloadData()
                    self.tableViewData = mogakDataArray.map { mogakData in
                        return MogakJogak(mogaktitle: mogakData.title, jogaktitle: ["1"])
                    }
                    for (index, mogakData) in mogakDataArray.enumerated() {
                        
                        if index < self.tableViewData.count {
                            self.tableViewData[index].mogaktitle = mogakData.title
                            print("배열안의 mogaktitle : ", self.tableViewData[index].mogaktitle)
                            self.getDetailJogakData(id: mogakData.mogakId)
                        }
                        
                        self.MogakTableView.reloadData()
                    }
                    
                    //                    DispatchQueue.main.async {
                    //                        self.MogakTableView.reloadData()
                    //
                    //                    }
                    
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
                    
                    for jogakDataItem in jogakDetailArray {
                        if let mogakDataIndex = self.tableViewData.firstIndex(where: { $0.mogaktitle == jogakDataItem.mogakTitle }) {
                            
                            self.tableViewData[mogakDataIndex].jogaktitle.append(jogakDataItem.title)
                            
                            print("배열안의 jogaktitle : ", self.tableViewData[mogakDataIndex])
                        }
                        
                        
                    }
                    self.MogakTableView.reloadData()
                    
                }
                
            case.failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            }
        }
    }
    
    
}

extension SelectJogakModal: ExpyTableViewDelegate, ExpyTableViewDataSource {
    
    func tableView(_ tableView: ExpyTableView, expyState state: ExpyState, changeForSection section: Int) { //섹션이 열리고 닫히기
        
        switch state {
        case .willExpand:
            print("WILL EXPAND")
            
        case .willCollapse:
            print("WILL COLLAPSE")
            
        case .didExpand:
            print("DID EXPAND")
            
        case .didCollapse:
            print("DID COLLAPSE")
        }
    }
    //MARK: - tableView Setting
    
    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        return true
    }
    //MARK: - Mogak
    
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        guard section < tableViewData.count else {
            // 섹션 번호가 배열의 인덱스 범위를 벗어나면 빈 셀을 반환하거나 에러 처리를 할 수 있습니다.
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MogakTableViewCell") as? MogakTableViewCell else {
            return UITableViewCell()
        }
        
        // 현재 섹션의 모각에 해당하는 mogaktitle 가져오기
        let mogakTitle = tableViewData[section].mogaktitle
        
        // 셀에 mogakTitle 표시
        // cell.configureMogak(with: mogakTitle)
        cell.textLabel?.text = mogakTitle
        
        return cell
    }
    
    func numberOfSections(in: UITableView) -> Int {
        if let firstMogakJogak = tableViewData.first, firstMogakJogak.mogaktitle.count == 0 {
            return 0
        } else {
            return tableViewData.count
        }
    }
    //MARK: - Jogak
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //조각의 개수
        
        guard section < tableViewData.count else {
            MogakTableView.reloadData()
            return 0
        }
        
        
        // section에 해당하는 배열 요소의 jogaktitle 개수 반환
        return tableViewData[section].jogaktitle.count
    }
    
    //MARK: - cell에 해당하는 row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MogakTableViewCell") else {
            return UITableViewCell()
        }
        let jogakTitle = tableViewData[indexPath.section].jogaktitle[indexPath.row]
        
        
        cell.textLabel?.text = jogakTitle
        return cell
    }
    
    
    //    func handleJogakSelection(_ jogakLabel: String) {
    //
    //        print("JogakLabel: \(jogakLabel) 추가됨!")
    //
    //        self.SelectJogaklist.append(jogakLabel)
    //
    //        print("SelectJogaklist에 추가: \(self.SelectJogaklist)")
    //    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 60
        }else {
            return 40
        }
        
    }
    
    //    //MARK: - 셀 클릭시 반응
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section < mogakData.count else {
            self.MogakTableView.reloadData()
            return
        }
        
        // 선택된 indexPath의 모각의 mogakId 출력
        print(mogakData[indexPath.section].mogakId)
        
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
//MARK: - tableViewCell

class MogakTableViewCell : UITableViewCell{
    
    private lazy var MogakLabel : CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 12, bottom: 12, left: 20, right: 20)
        label.font = DesignSystemFont.medium16L150.value
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var MogakView : UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var MogakStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [MogakView,MogakButtonView])
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.backgroundColor = .white
        return stackView
    }()
    
    private lazy var MogakButtonView : UIImageView = {
        let MogakButton = UIImageView()
        MogakButton.image = UIImage(systemName: "chevron.up")
        MogakButton.tintColor = DesignSystemColor.icongray.value
        return MogakButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func layout(){
        contentView.addSubview(MogakStackView)
        MogakView.addSubview(MogakLabel)
        
        MogakStackView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        MogakView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.bottom.equalToSuperview().inset(12)
        }
        
        MogakLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        MogakButtonView.snp.makeConstraints {
            $0.width.height.equalTo(16)
            $0.centerY.equalTo(MogakLabel)
            $0.trailing.equalToSuperview()
        }
    }
    
    func configureMogak(with mogakData: ScheduleDetailMogakData) {
        
        MogakLabel.text = mogakData.title
        
        if mogakData.color == nil{
            MogakLabel.textColor = DesignSystemColor.signature.value
            MogakLabel.backgroundColor = DesignSystemColor.signature.value.withAlphaComponent(0.1)
            print("if")
        }else{
            MogakLabel.backgroundColor = UIColor(hex: mogakData.color ?? "").withAlphaComponent(0.1)
            MogakLabel.textColor = UIColor(hex: mogakData.color ?? "")
            
        }
        
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

