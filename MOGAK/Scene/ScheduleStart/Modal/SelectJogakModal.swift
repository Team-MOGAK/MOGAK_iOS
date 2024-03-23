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
    
    //셀
    var SelectJogaklist : [String] = [] // 루틴으로 지정된 조각
    
    //모다라트
    var modalartList: [ScheduleModalartList] = []
    
    var modalartTitles: [String] = []
    
    var nowShowModalArtNum: Int = 0
    var nowShowModalArtIndex: Int = 0
    
    
    var mogakDataCategory: [ScheduleMogakCategory] = []
    
    var jogakData: [ScheduleJogakDetail] = []
    var mogakData: [ScheduleDetailMogakData] = []
    
    let Apinetwork =  ApiNetwork.shared
    
    let DidDismissModal: Notification.Name = Notification.Name("DidDismissModal")
    
    
    
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
        super.viewWillAppear(animated)
        getModalart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: self.DidDismissModal, object: nil, userInfo: nil)
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
    struct MogakJogak {
        var mogaktitle: String
        var mogakcolor: String
        var jogakList: [(title: String, isAlreadyAdded: Bool, isRoutine: Bool, jogakID : Int)]
    }
    
    var tableViewData = [MogakJogak]()
    //MARK: - tableView UI
    
    func tableSetUI() {
        //아니, 테이블 뷰 하나에 셀 두개가 된다고????????????????????
        //시발 진작 알려주지 이거때매 3주는 고생했고만 ;;;
        MogakTableView.register(MogakTableViewCell.self, forCellReuseIdentifier: "MogakTableViewCell")
        MogakTableView.register(JogakTableViewCell.self, forCellReuseIdentifier: "JogakTableViewCell")
        
        MogakTableView.reloadData()
        MogakTableView.dataSource = self
        MogakTableView.delegate = self
        MogakTableView.separatorStyle = .none
        
        tableViewData = [MogakJogak(mogaktitle: "", mogakcolor: "", jogakList: [(title: "", isAlreadyAdded: false, isRoutine: false, jogakID: 0)])
        ]
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
                
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: currentDate)
                
                if let mogakDataArray = data?.result?.mogaks{
                    self.mogakData = mogakDataArray
                    self.MogakTableView.reloadData()
                    self.tableViewData = mogakDataArray.map { mogakData in
                        
                        return MogakJogak(mogaktitle: mogakData.title, mogakcolor: mogakData.color ?? "", jogakList: [(title: "1", isAlreadyAdded: false,isRoutine: false, jogakID : 0)])
                    }
                    
                    for (index, mogakData) in mogakDataArray.enumerated() {
                        
                        if index < self.tableViewData.count {
                            self.tableViewData[index].mogaktitle = mogakData.title
                            self.getDetailJogakData(id: mogakData.mogakId, DailyDate: dateString) //조각불러오기
                        }
                        
                        self.MogakTableView.reloadData()
                    }
                    
                } else {
                    
                }
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            }
        }
    }
    //MARK: - 한 모각에 대응하는 조각보기
    func getDetailJogakData(id : Int, DailyDate : String){
        Apinetwork.getAllMogakDetailJogaks(mogakId: id, DailyDate: DailyDate){result in
            switch result{
            case.success(let data):
                
                if let jogakDetailArray = data {
                    
                    for jogakDataItem in jogakDetailArray {
                        if let mogakDataIndex = self.tableViewData.firstIndex(where: { $0.mogaktitle == jogakDataItem.mogakTitle }) {
                            
                            let isAlreadyAddedValue = jogakDataItem.isAlreadyAdded
                            let JogakIdValue = jogakDataItem.jogakID
                            let isRoutineValue = jogakDataItem.isRoutine
                            
                            self.tableViewData[mogakDataIndex].jogakList.append((title: jogakDataItem.title, isAlreadyAdded: isAlreadyAddedValue, isRoutine: isRoutineValue, jogakID : JogakIdValue))
                        }
                        
                    }
                    self.MogakTableView.reloadData()
                    
                }
                
            case.failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            }
        }
    }
    //MARK: - 일일 조각 시작
    func getAddJogakDaily(jogakId : Int){
        Apinetwork.getAddJogakDaily(jogakId: jogakId){ result in
            switch result{
            case.success(let data):
                print(data as Any)
                
            case.failure(let error):
                print(error)
            }
        }
    }
    
}

extension SelectJogakModal: ExpyTableViewDelegate, ExpyTableViewDataSource {
    
    func tableView(_ tableView: ExpyTableView, expyState state: ExpyState, changeForSection section: Int) { //섹션이 열리고 닫히기
        
        switch state {
        case .willExpand:
            return
            
        case .willCollapse:
            return
            
        case .didExpand:
            return
            
        case .didCollapse:
            return
        }
    }
    //MARK: - tableView Setting
    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        return true
    }
    
    //MARK: - Mogak
    
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        
        guard section < tableViewData.count else {
            MogakTableView.reloadData() ///이거 안하면 테이블뷰 오류나요ㅠㅠㅠㅠㅠ ㅅㅣ발
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MogakTableViewCell") as? MogakTableViewCell else {
            return UITableViewCell()
        }
        
        // 현재 섹션의 모각에 해당하는 mogaktitle 가져오기
        let mogakdata = tableViewData[section]
        
        // 셀에 mogakTitle 표시
        cell.configureMogak(with: mogakdata)
        
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
        return tableViewData[section].jogakList.count
    }
    
    //MARK: - cell에 해당하는 row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "JogakTableViewCell", for: indexPath) as? JogakTableViewCell else {
            
            return UITableViewCell()
        }
        
        let jogakData = tableViewData[indexPath.section].jogakList[indexPath.row]
        cell.configureJogak(with: jogakData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 60
        }else {
            return 40
        }
        
    }
    //MARK: - 추가하기 버튼 클릭시
    @objc func addJogak() {
        dismiss(animated: true, completion: { [self] in
            let serialQueue = DispatchQueue(label: "com.example.serialQueue")
            
            for jogakId in UserDefaultsManager.shared.clickedJogakIdList {
                serialQueue.async {
                    self.getAddJogakDaily(jogakId: jogakId)
                    print(jogakId , "호출 완료")
                }
            }
            serialQueue.async {
                UserDefaultsManager.shared.clickedJogakIdList.removeAll()
            }
        })
    }

    
}

extension Date {
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
}
//MARK: - MogakTableViewCell
#warning("MogakTableViewCell")
class MogakTableViewCell : UITableViewCell,ExpyTableViewHeaderCell{
    
    func changeState(_ state: ExpyState, cellReuseStatus cellReuse: Bool) {
        switch state {
        case .willExpand:
            MogakButtonView.image = UIImage(systemName: "chevron.up")
            
        case .willCollapse:
            MogakButtonView.image = UIImage(systemName: "chevron.down")
            
        case .didExpand:
            return
            
        case .didCollapse:
            return
        }
        
    }
    
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
        let stackView = UIStackView(arrangedSubviews: [MogakView])
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
        layoutMogak()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func layoutMogak(){
        contentView.addSubviews(MogakStackView,MogakButtonView)
        MogakView.addSubview(MogakLabel)
        
        MogakStackView.snp.makeConstraints{
            $0.edges.equalToSuperview()
            
        }
        
        MogakView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.bottom.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
        
        MogakLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalTo(MogakStackView)
        }
        
        MogakButtonView.snp.makeConstraints {
            $0.width.height.equalTo(16)
            $0.centerY.equalTo(MogakStackView)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func configureMogak(with mogakData: SelectJogakModal.MogakJogak) {
        
        MogakLabel.text = mogakData.mogaktitle
        
        if mogakData.mogakcolor.isEmpty{
            MogakLabel.textColor = DesignSystemColor.signature.value
            MogakLabel.backgroundColor = DesignSystemColor.signature.value.withAlphaComponent(0.1)
            print("if")
        }else{
            MogakLabel.backgroundColor = UIColor(hex: mogakData.mogakcolor ).withAlphaComponent(0.1)
            MogakLabel.textColor = UIColor(hex: mogakData.mogakcolor)
            
        }
        
    }
}
//MARK: - JogakTableViewCell
#warning("JogakTableViewCell")

class JogakTableViewCell : UITableViewCell{
    
    var jogakSelectionHandler: (() -> Void)?
    
    private lazy var JogakLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PretendardVariable-Medium", size: 16)
        let labeltap = UITapGestureRecognizer(target: self, action: #selector(jogakLabelTap))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(labeltap)
        return label
    }()
    
    private lazy var JogakimageView : UIImageView = {
        let image = UIImageView()
        image.tintColor = UIColor(red: 0.749, green: 0.766, blue: 0.833, alpha: 1)
        let labeltap = UITapGestureRecognizer(target: self, action: #selector(jogakLabelTap))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(labeltap)
        return image
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        layoutJogak()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    func layoutJogak(){
        contentView.addSubviews(JogakLabel,JogakimageView)
        
        JogakLabel.snp.makeConstraints {
            $0.leading.equalTo(JogakimageView).inset(25)
            $0.top.bottom.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        JogakimageView.snp.makeConstraints{
            $0.width.height.equalTo(20)
            $0.leading.equalToSuperview().inset(40)
            $0.centerY.equalTo(JogakLabel)
        }
    }
    
    var clickedJogakId : Int = 0
    
    //MARK: - 조각 라벨 설정
    func configureJogak(with jogakData: (title: String, isAlreadyAdded: Bool, isRoutine: Bool, jogakID : Int)) {
        JogakLabel.text = jogakData.title
        
        clickedJogakId = jogakData.jogakID
        
        print("조각 타이틀 : \(jogakData.title) 일일 조각 추가 여부 : \(jogakData.isAlreadyAdded) 루틴의 여부 :\(jogakData.isRoutine) 조각 아이디: \(jogakData.jogakID)")
        
        //이미 일일 조각에 추가가 되어있을 경우 || == or
        if (jogakData.isAlreadyAdded || jogakData.isRoutine) == true{
            JogakimageView.image = UIImage(systemName: "checkmark.square.fill")?.withTintColor(DesignSystemColor.lightGreen.value, renderingMode: .alwaysOriginal)
            
        } else {
            JogakimageView.image = UIImage(systemName: "square")
            
            if UserDefaultsManager.shared.clickedJogakIdList.contains(clickedJogakId) {
                JogakimageView.image = UIImage(systemName: "checkmark.square.fill")?.withTintColor(DesignSystemColor.lightGreen.value, renderingMode: .alwaysOriginal)
            }else{
                JogakimageView.image = UIImage(systemName: "square")
            }
        }
        JogakimageView.isUserInteractionEnabled = !(jogakData.isAlreadyAdded || jogakData.isRoutine)
            JogakLabel.isUserInteractionEnabled = !(jogakData.isAlreadyAdded || jogakData.isRoutine)
    }
    
    //MARK: - jogakLabel 클릭시 이벤트
    @objc func jogakLabelTap(_ sender: UITapGestureRecognizer){
        
        print(JogakLabel.text ?? "", clickedJogakId)
        
        if JogakimageView.image == UIImage(systemName: "square"){
            
            UserDefaultsManager.shared.clickedJogakIdList.append(clickedJogakId)
            
            JogakimageView.image = UIImage(systemName: "checkmark.square.fill")?.withTintColor(DesignSystemColor.lightGreen.value, renderingMode: .alwaysOriginal)
        }else{
            JogakimageView.image = UIImage(systemName: "square")
            if let index = UserDefaultsManager.shared.clickedJogakIdList.firstIndex(of: clickedJogakId) {
                UserDefaultsManager.shared.clickedJogakIdList.remove(at: index)
            }
        }
        print("찐배열 \(UserDefaultsManager.shared.clickedJogakIdList)")
        jogakSelectionHandler?()
    }
}

//싱글톤 패턴 적용
class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private init () {}
    
    var clickedJogakIdList: [Int] = []
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

