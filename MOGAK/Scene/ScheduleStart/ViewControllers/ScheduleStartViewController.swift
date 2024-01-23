//
//  ViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit
import SnapKit
import FSCalendar
import Then
import Alamofire

class ScheduleStartViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance, UISheetPresentationControllerDelegate{
    
    var dailyJogak: [String] = [] // 일일조각 리스트
    
    let Apinetwork =  ApiNetwork.shared
    
    
    //MARK: - Properties
    
    private lazy var calendarView : FSCalendar = {
        let calendarView = FSCalendar(frame: .zero)
        calendarView.backgroundColor = .white
        return calendarView
    }()
    
    private lazy var headerDataFormatter = DateFormatter().then {
        $0.dateFormat = "YYYY년 MM월"
        $0.locale = Locale(identifier : "ko_kr")
        $0.timeZone = TimeZone(identifier : "KST")
    }
    
    private lazy var toggleButton : UIButton = { //기본값
        let toggleButton = UIButton()
        toggleButton.setImage(UIImage(named: "week"), for: .normal)
        toggleButton.backgroundColor = .clear //백그라운드색
        toggleButton.layer.cornerRadius = 8 //둥글기
        toggleButton.addTarget(self, action: #selector(tapToggleButton), for: .touchUpInside)
        return toggleButton
    }()
    
    private lazy var leftButton : UIButton = {
        let leftButton = UIButton()
        leftButton.backgroundColor = .clear
        leftButton.setImage(UIImage(named: "<"), for: .normal) //이미지 수정
        leftButton.addTarget(self, action: #selector(tapBeforeWeek), for: .touchUpInside)
        return leftButton
    }()
    
    private lazy var rightButton : UIButton = {
        let rightButton = UIButton()
        rightButton.backgroundColor = .clear
        rightButton.setImage(UIImage(named: ">"), for: .normal) //이미지수정
        rightButton.addTarget(self, action: #selector(tapNextWeek), for: .touchUpInside)
        return rightButton
    }()
    
    private lazy var headerLabel = UILabel().then { [weak self] in
        guard let self = self else { return }
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.textColor = .label
        $0.text = self.headerDataFormatter.string(from: Date())
        $0.textAlignment = .center
    }
    
    
    private lazy var upperView : UIView = {
        let upperView = UIView()
        upperView.backgroundColor = .white
        return upperView
    }()
    
    private lazy var motiveLabel : UILabel = {
        let motiveLabel = UILabel()
        motiveLabel.text = "오늘도 조금씩 더 나은 내일을 위해, 조각을 시작해 볼까요?"
        motiveLabel.textColor = UIColor(hex: "#6E707B")
        motiveLabel.font = UIFont(name: "Pretendard-Regular", size: 14)
        return motiveLabel
    }()
    
    private lazy var blankimage : UIImageView = {
        let blankimage = UIImageView()
        blankimage.image = UIImage(named: "blankImage")
        blankimage.clipsToBounds = true
        return blankimage
    }()
    
    private lazy var blankLabel : UILabel = {
        let blankLabel = UILabel()
        blankLabel.text = "내 조각이 없어요...\n모다라트를 먼저 생성해 볼까요?"
        blankLabel.font = UIFont(name: "Pretendard", size: 16)
        blankLabel.textColor = UIColor(hex: "#808497")
        blankLabel.numberOfLines = 2
        blankLabel.textAlignment = .center
        return blankLabel
    }()
    
    
    private lazy var makeModalArt : UIButton = {
        let makeModalArt = UIButton()
        makeModalArt.backgroundColor = UIColor(red: 0.883, green: 0.899, blue: 1, alpha: 1)
        makeModalArt.layer.cornerRadius = 15 //둥글기
        makeModalArt.setTitle("모다라트 만들러가기", for: .normal)
        makeModalArt.setTitleColor(DesignSystemColor.signature.value, for: .normal)
        makeModalArt.titleLabel?.font =  DesignSystemFont.medium12L150.value
        makeModalArt.addTarget(self, action: #selector(goSchedule), for: .touchUpInside)
        return makeModalArt
    }()
    
    private lazy var underView : UIView = {
        let underView = UIView()
        underView.backgroundColor = .clear
        return underView
    }()
    
    lazy var ScheduleTableView : UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 10
        return tableView
    }()
    
    private lazy var startButton : UIButton = {
        let startbutton = UIButton()
        startbutton.setTitle("오늘 할 조각 추가하기",for : .normal) //타이틀
        startbutton.setTitleColor(.white, for : .normal) //글자 색
        startbutton.backgroundColor = DesignSystemColor.signature.value  //백그라운드색
        startbutton.titleLabel?.font = DesignSystemFont.semibold18L100.value
        startbutton.layer.cornerRadius = 10 //둥글기
        //        startbutton.isHidden = true
        startbutton.addTarget(self, action: #selector(goStart), for: .touchUpInside)
        return startbutton
    }()
    
    private var isToday: Bool {
        let selectedDate = calendarView.selectedDate ?? Date()
        let today = Date()
        
        return Calendar.current.isDate(selectedDate, inSameDayAs: today)
    }
    
    let selectJogakModal = SelectJogakModal()
    
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor(hex: "F1F3FA")
        self.motiveLabel.isHidden = true
        self.configureUI()
        self.configureCalendar()
        self.tableSetting()
        tableViewUI() //table뷰 보여줌
        startButton.isHidden = !isToday
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateString = dateFormatter.string(from: currentDate)
        
        self.CheckDailyJogaks(DailyDate: dateString)
        
        self.ScheduleTableView.reloadData()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    //MARK: - Calendar func
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarView.snp.updateConstraints{make in
            make.height.equalTo(bounds.height)
        }
        self.view.layoutIfNeeded()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentPage = calendar.currentPage
        headerLabel.text = headerDataFormatter.string(from: currentPage)
    }
    
    //MARK: - 날짜 선택 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        ScheduleTableView.reloadData()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // 원하는 날짜 형식으로 변경
        
        let dateString = dateFormatter.string(from: date)
        
        print(dateString)
        self.CheckDailyJogaks(DailyDate: dateString)
        startButton.isHidden = !isToday
        
    }
    //MARK: - 날짜에 이벤트 dots
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        return 0
    }
    
    //MARK: - Default Event Dot 색상 분기처리 - FSCalendarDelegateAppearance
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]?{
        
        return nil
    }
    
    //MARK: - Selected Event Dot 색상 분기처리 - FSCalendarDelegateAppearance
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        
        return nil
    }
    
    //MARK: - configureUI
    private func configureUI(){
        
        let headerStackView = UIStackView(arrangedSubviews: [leftButton,headerLabel,rightButton]).then{
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            
            headerLabel.snp.makeConstraints{
                $0.height.equalTo(28.0)
                $0.width.equalTo(110)
                
            }
        }
        
        
        [upperView,calendarView,motiveLabel,toggleButton,headerStackView,underView,blankimage,blankLabel,makeModalArt].forEach{view.addSubviews($0)}
        
        
        
        headerStackView.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(26)
            $0.leading.equalTo(calendarView.collectionView)
        }
        
        calendarView.snp.makeConstraints{
            $0.top.equalTo(headerStackView.snp.bottom).offset(5) //달력 대가리
            $0.trailing.leading.equalToSuperview().inset(20)
            $0.height.equalTo(200) // 캘린더뷰의(월)일때의 총 높이
        }
        
        toggleButton.snp.makeConstraints{
            $0.bottom.equalTo(headerStackView.snp.bottom)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(30)
            $0.width.equalTo(49)
        }
        
        upperView.snp.makeConstraints{
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(calendarView.snp.bottom)
        }
        
        underView.snp.makeConstraints{
            $0.top.equalTo(calendarView.snp.bottom).offset(20)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        motiveLabel.snp.makeConstraints{
            $0.top.equalTo(calendarView.snp.bottom).offset(16)
            $0.leading.equalTo(calendarView.collectionView)
        }
        
        blankimage.snp.makeConstraints{
            $0.bottom.equalTo(blankLabel.snp.top).offset(-10)
            $0.width.height.equalTo(88.0)
            $0.centerX.equalToSuperview()
        }
        
        blankLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(10)
        }
        
        makeModalArt.snp.makeConstraints{
            $0.top.equalTo(blankLabel.snp.bottom).offset(10)
            $0.width.equalTo(153)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
        }
        
    }
    
    //MARK: - configureCalendar
    
    private func configureCalendar(){
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.select(Date())
        
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.scope = .week
        //달력 안에 동그라미 표시 수정요망
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        calendarView.appearance.selectionColor = UIColor(hex: "#475FFD")
        calendarView.appearance.borderRadius = 0.4
        
        let offset: Double = (self.view.frame.width - ("YYYY년 MM월"as NSString)
            .size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)])
            .width - 16.0 ) / 2.0
        
        calendarView.appearance.headerTitleOffset = CGPoint(x: -offset, y: 0)
        calendarView.weekdayHeight = 33
        calendarView.headerHeight = 0
        
        
        calendarView.appearance.weekdayFont = UIFont(name: "Pretendard", size: 12)
        calendarView.appearance.titleDefaultColor = UIColor(hex: "#200E04")
        calendarView.appearance.titleFont = UIFont(name: "Pretendard", size: 16)
        calendarView.appearance.titleTodayColor = UIColor(hex: "#200E04")
        calendarView.appearance.todayColor = .white
        calendarView.appearance.weekdayTextColor = UIColor(hex: "#808080")
        calendarView.placeholderType = .none
        
        calendarView.scrollEnabled = true
        calendarView.scrollDirection = .horizontal
    }
    
    
    func getNextWeek(date : Date) -> Date {
        return Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: date)!
    }
    
    func getProviousWeek(date : Date) -> Date {
        return Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: date)!
    }
    
    //MARK: - 햄치즈토스트 팝업 맨~
    func showToast(message : String, font: UIFont) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 112, y: self.view.frame.size.height-150, width: 224, height: 29))
        toastLabel.backgroundColor = UIColor(red: 0.142, green: 0.147, blue: 0.179, alpha: 0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 16;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    //MARK: - 일일 조각 API 호출 맨~
    func CheckDailyJogaks(DailyDate: String){
        Apinetwork.getCheckDailyJogak(DailyDate: DailyDate) { result in
            switch result {
            case .success(let jogakDailyChecks):
                if let jogakDailyChecks = jogakDailyChecks {
                    print("일일 조각 리스트 : ",self.dailyJogak)
                    self.dailyJogak = []
                    for jogakDailyCheck in jogakDailyChecks {
                        let result = jogakDailyCheck.result
                        
                        for dailyJogak in result.dailyJogaks {
                            self.dailyJogak.append(dailyJogak.title)
                        }
                    }
                    print(self.dailyJogak)
                    self.ScheduleTableView.reloadData()
                } else {
                    print("일일 조각을 위한 nil 배열 수신.")
                }
            case .failure(let error):
                print("뷰컨에서 failure",error)
            }
        }
        
        
    }
    
    
    //MARK: - @objc
    @objc func tapToggleButton(){
        if self.calendarView.scope == .month {
            self.calendarView.setScope(.week, animated: true)
            self.headerDataFormatter.dateFormat = "YYYY년 MM월"
            self.toggleButton.setImage(UIImage(named: "week"), for: .normal)
            self.headerLabel.text = headerDataFormatter.string(from: calendarView.currentPage)
        }else{
            self.calendarView.setScope(.month, animated: true)
            self.headerDataFormatter.dateFormat = "YYYY년 MM월"
            self.toggleButton.setImage(UIImage(named: "month"), for: .normal)
            self.headerLabel.text = headerDataFormatter.string(from: calendarView.currentPage)
        }
    }
    
    
    @objc func goSchedule(_ sender : UIButton){
        print("여기 모다라트 만드는거 연결")
        ScheduleTableView.reloadData()
    }
    
    @objc func goAlarm(_ sender : UIButton){
        let alarmVC = AlarmViewController()
        navigationController?.pushViewController(alarmVC, animated: true)
        print("go alarm")
    }
    
    @objc func goStart(_ sender : UIButton){
        
        let selectJogak = SelectJogakModal()
        selectJogak.modalPresentationStyle = .pageSheet
        
        selectJogak.TableViewReload = { [weak self] in
            self?.ScheduleTableView.reloadData()
            
            print("reload data")
            
        }
        
        present(selectJogak, animated: true, completion: nil)
        
        if let sheet = selectJogak.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.delegate = self
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = nil
        }
        
        print("timer setRoutie")
    }
    
    @objc func tapNextWeek(_ sender : UIButton){
        if calendarView.scope == .week {
            self.calendarView.setCurrentPage(getNextWeek(date: calendarView.currentPage), animated: true)
            print("TapNextWeek")
        } else {
            let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: calendarView.currentPage)
            calendarView.setCurrentPage(nextDate!, animated: true)
            headerLabel.text = headerDataFormatter.string(from: nextDate!)
            print("TapNextMonth")
        }
    }
    
    @objc func tapBeforeWeek(_ sender : UIButton){
        if calendarView.scope == .week {
            self.calendarView.setCurrentPage(getProviousWeek(date: calendarView.currentPage), animated: true)
            print("TapBeforeWeek")
            
        } else {
            let previousDate = Calendar.current.date(byAdding: .month, value: -1, to: calendarView.currentPage)
            calendarView.setCurrentPage(previousDate!, animated: true)
            headerLabel.text = headerDataFormatter.string(from: previousDate!)
            print("TapBeforeMonth")
        }
    }
}

//MARK: - tableview

extension ScheduleStartViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableSetting(){
        ScheduleTableView.delegate = self
        ScheduleTableView.dataSource = self
        ScheduleTableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "ScheduleTableViewCell")
        ScheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        
        underView.addSubview(motiveLabel)
        underView.addSubview(ScheduleTableView)
        underView.addSubview(startButton)
        
        ScheduleTableView.snp.makeConstraints{
            $0.top.equalTo(motiveLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(calendarView.collectionView)
            $0.bottom.equalTo(startButton.snp.top)
        }
        
        startButton.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            //$0.top.equalTo(ScheduleTableView.snp.bottom)
            $0.bottom.equalTo(underView.snp.bottom).inset(110) //16
            $0.height.equalTo(48)
        }
    }
    
    func tableViewUI(){
        ScheduleTableView.reloadData()
        self.ScheduleTableView.backgroundColor = .clear
        ScheduleTableView.separatorStyle = .none
        
    }
    
    //MARK: -  Cell설정 (셀로부터 이동되는 정보들)
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){ //셀 클릭
        guard let cell = ScheduleTableView.cellForRow(at: indexPath) as? ScheduleTableViewCell else {
            
            return
        }
        
        cell.contentView.backgroundColor = UIColor.white
        
        let Certificate = CertificationModalVC()
        
        Certificate.modalPresentationStyle = .pageSheet
        
        if cell.cellImage.image == UIImage(named: "emptySquareCheckmark"){
            cell.cellImage.image = UIImage(named: "squareCheckmark")
            Certificate.titleLabel.text = "'" + cell.cellLabel.text! + "'" + "\n오늘 조각을 완료하셨군요!"
            
            NotificationCenter.default.addObserver(self, selector: #selector(dataReceived(_:)), name: NSNotification.Name("RecordText"), object: nil)
            
            present(Certificate, animated: true)
            
            if let sheet = Certificate.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.delegate = self
                sheet.prefersGrabberVisible = true
                sheet.largestUndimmedDetentIdentifier = nil
                
            }
            
        } else{
            cell.cellImage.image = UIImage(named: "emptySquareCheckmark")
            
        }
    }
    
    @objc func dataReceived(_ notification : Notification){
        if let text = notification.object as? String{
            
            print("Received text: \(text)")
            
            if let indexPath = ScheduleTableView.indexPathForSelectedRow {
                let cell = ScheduleTableView.cellForRow(at: indexPath) as? ScheduleTableViewCell
                cell?.recodelabel?.text = text
                
            }
        }
    }
    
    //MARK: - Cell Selction
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numberOfJogak = dailyJogak.count
        
        if numberOfJogak == 0 {
            blankimage.isHidden = false
            blankLabel.isHidden = false
            makeModalArt.isHidden = false
            motiveLabel.isHidden = true
            
        } else {
            blankimage.isHidden = true
            blankLabel.isHidden = true
            makeModalArt.isHidden = true
            motiveLabel.isHidden = false
            
        }
        
        return numberOfJogak
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard let cell = tableView.cellForRow(at: indexPath) as? ScheduleTableViewCell else {
                return 80.0 // Default height
            }
            
            // 셀 내의 recodelabel의 동적 높이를 계산하는 메서드를 사용합니다
            let recodelabelHeight = cell.calculateRecodelabelHeight()
            
            // 동적 높이를 기본 셀 높이에 추가합니다
            return 80.0 + recodelabelHeight
        }
    
    //MARK: - cellUI
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //cell 재활용
        guard let cell = ScheduleTableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as? ScheduleTableViewCell else {return UITableViewCell()} //셀 재사용
        
        cell.cellLabel.text = dailyJogak[indexPath.row]
        
        cell.contentView.backgroundColor = .white
        cell.selectionStyle = .none //클릭시 화면 안바뀜
        cell.backgroundColor = .clear
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        
        return cell
        
    }
    
    
}

//extension ScheduleStartViewController: ScheduleTimerDelegate {
//    
//    func certificateModal() {
//        print("프린트 서티피케이트")
//        let scheduleDone = CertificationModalVC()
//        scheduleDone.modalPresentationStyle = .formSheet
//        self.present(scheduleDone,animated: true)
//        
//        if let sheet = scheduleDone.sheetPresentationController{
//            sheet.detents = [.medium()]
//            sheet.delegate = self
//            sheet.prefersGrabberVisible = true
//            sheet.largestUndimmedDetentIdentifier = nil
//        }
//    }
//}



