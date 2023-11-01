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
    
    //MARK: - Properties
    
    private lazy var calendarView : FSCalendar = {
        let calendarView = FSCalendar(frame: .zero)
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
    
    private lazy var ScheduleTableView : UITableView = {
        let ScheduleTableView = UITableView()
        ScheduleTableView.layer.cornerRadius = 10
        return ScheduleTableView
    }()
    
    private lazy var startButton : UIButton = {
        let startbutton = UIButton()
        startbutton.setTitle("오늘 할 조각 추가하기",for : .normal) //타이틀
        startbutton.setTitleColor(.white, for : .normal) //글자 색
        startbutton.backgroundColor = DesignSystemColor.signature.value//백그라운드색
        startbutton.titleLabel?.font = DesignSystemFont.semibold18L100.value
        startbutton.layer.cornerRadius = 10 //둥글기
        startbutton.addTarget(self, action: #selector(goStart), for: .touchUpInside)
        return startbutton
    }()
    
    var circularProgressView = CircularProgressView()
    
    //MARK: - CellAarray
    
    //var cellArray = ["두줄까지 쓸 수 있어요.\n두줄까지 쓸 수 있어요.","물론 한줄도 가능합니다.","근데 세줄은 할수 없습니다.","4번째 셀","5번째 셀"]
    
    var cellArray = ["0번째 셀입니다.","1번째 셀입니다.","2번째 셀입니다."]
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.circularProgressView.isHidden = true
        //        self.startButton.isHidden = true
        self.motiveLabel.isHidden = true
        view.backgroundColor = UIColor(hex: "F1F3FA")
        self.configureUI()
        self.configureCalendar()
        self.tableSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.ScheduleTableView.reloadData()
        // print("배열 \(cellArray)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        //        self.ScheduleTableView.isHidden = true
        self.motiveLabel.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
        //        self.ScheduleTableView.isHidden = true
        self.motiveLabel.isHidden = true
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
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        ScheduleTableView.reloadData()
        
        blankimage.isHidden = false
        blankLabel.isHidden = false
        makeModalArt.isHidden = false
        //        startButton.isHidden = true
        ScheduleTableView.isHidden = true
        motiveLabel.isHidden = true
        
        
    }
    
    // 날짜 선택 해제 콜백 메소드
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
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
        
        
        [upperView,calendarView,motiveLabel,toggleButton,headerStackView,underView,blankimage,blankLabel,makeModalArt,startButton,circularProgressView].forEach{view.addSubview($0)}
        
        
        
        headerStackView.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(26)
            $0.leading.equalTo(calendarView.collectionView)
        }
        
        calendarView.snp.makeConstraints{
            $0.top.equalTo(headerStackView.snp.bottom).offset(5) //달력 대가리
            $0.trailing.leading.equalToSuperview().inset(12)
            $0.height.equalTo(200) // 캘린더뷰의(월)일때의 총 높이
        }
        
        toggleButton.snp.makeConstraints{
            $0.bottom.equalTo(headerStackView.snp.bottom)
            $0.trailing.equalTo(calendarView.collectionView)
            $0.height.equalTo(30)
            $0.width.equalTo(49)
        }
        
        upperView.snp.makeConstraints{
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(calendarView.snp.bottom)
        }
        
        underView.snp.makeConstraints{
            $0.top.equalTo(calendarView.snp.bottom)
            $0.leading.trailing.equalTo(calendarView.collectionView)
            $0.bottom.equalToSuperview()
        }
        
        motiveLabel.snp.makeConstraints{
            $0.top.equalTo(calendarView.snp.bottom).offset(16)
            $0.leading.equalTo(calendarView.collectionView)
        }
        
        blankimage.snp.makeConstraints{
            $0.top.equalTo(upperView.snp.bottom).offset(100)
            $0.width.height.equalTo(88.0)
            $0.centerX.equalToSuperview()
        }
        
        blankLabel.snp.makeConstraints{
            $0.top.equalTo(blankimage.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        makeModalArt.snp.makeConstraints{
            $0.top.equalTo(blankLabel.snp.bottom).offset(22)
            $0.width.equalTo(153)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
        }
        
        startButton.snp.makeConstraints{
            $0.leading.trailing.equalTo(calendarView.collectionView)
            $0.bottom.equalToSuperview().inset(100)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
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
    
    @objc func goSetting(_ sender : UIButton){
        let settingVC = SettingViewController()
        navigationController?.pushViewController(settingVC, animated: true)
        print("go setting")
    }
    
    @objc func goSchedule(_ sender : UIButton){
        tableViewUI()
        print("go Schedule")
    }
    
    @objc func goAlarm(_ sender : UIButton){
        let alarmVC = AlarmViewController()
        navigationController?.pushViewController(alarmVC, animated: true)
        print("go alarm")
    }
    
    @objc func goStart(_ sender : UIButton){
        
        let startVC = ScheduleTimerVC()
        startVC.scheduleTimerDelegate = self
        navigationController?.pushViewController(startVC, animated: true)
        startVC.circularProgressView.Timerstart()
        
        print("timer Start")
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
        //        ScheduleTableView.isHidden = true
        
        underView.isHidden = true
        underView.addSubview(motiveLabel)
        underView.addSubview(ScheduleTableView)
        ScheduleTableView.snp.makeConstraints{
            $0.top.equalTo(motiveLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(calendarView.collectionView)
            $0.bottom.equalTo(startButton.snp.top).offset(-24)
        }
    }
    
    func tableViewUI(){
        blankimage.isHidden = true
        makeModalArt.isHidden = true
        blankLabel.isHidden = true
        
        ScheduleTableView.reloadData()
        
        self.ScheduleTableView.rowHeight = 80 //셀 높이
        self.ScheduleTableView.backgroundColor = .clear
        ScheduleTableView.separatorStyle = .none
        ScheduleTableView.isHidden = false
        motiveLabel.isHidden = false
        underView.isHidden = false
    }
    
    //MARK: -  Cell설정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //셀 클릭시 이벤트
        guard let cell = ScheduleTableView.cellForRow(at: indexPath) as? ScheduleTableViewCell else { //ScheduleTableViewCell을 사용
            return
        }
        cell.contentView.backgroundColor = UIColor.white
        
        if cell.cellImage.image == UIImage(named: "emptySquareCheckmark"){
            cell.cellImage.image = UIImage(named: "squareCheckmark")
            
            print("cell의 if문")
            
            let selectJogak = SelectJogakModal()
            selectJogak.modalPresentationStyle = .formSheet
            self.present(selectJogak,animated: true)
            
            if let sheet = selectJogak.sheetPresentationController{     //셀임의로 스크롤뷰. 우선적으로 라영님께 여쭤 보기 전임
                sheet.detents = [.medium()]
                sheet.delegate = self
                sheet.prefersGrabberVisible = true
                sheet.largestUndimmedDetentIdentifier = nil
            }
            
            
        } else{
            cell.cellImage.image = UIImage(named: "emptySquareCheckmark")
            print("cell의 else문")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) { //셀을 땟을때 이벤트
        guard let cell = ScheduleTableView.cellForRow(at: indexPath) as? ScheduleTableViewCell else { //ScheduleTableViewCell을 사용
            return
        }
        //셀의 기본설정
        cell.contentView.backgroundColor = .white
        cell.cellImage.image = UIImage(named: "emptySquareCheckmark")
        
        ScheduleTableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Cell Selction
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cellArray.count
    }
    
    //MARK: - cellUI
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //cell 재활용
        
        guard let cell = ScheduleTableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as? ScheduleTableViewCell else {return UITableViewCell()} //셀 재사용
        
        cell.cellLabel.text = cellArray[indexPath.row]
        cell.cellImage.image = UIImage(named: "emptySquareCheckmark")
        
        
        cell.contentView.backgroundColor = .white
        cell.selectionStyle = .none //클릭시 화면 안바뀜
        cell.backgroundColor = .clear
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        return cell
    }
    
    
}

extension ScheduleStartViewController: ScheduleTimerDelegate {
    
    func certificateModal() {
        print("프린트 서티피케이트")
        let scheduleDone = CertificationModalVC()
        scheduleDone.modalPresentationStyle = .formSheet
        self.present(scheduleDone,animated: true)
        
        if let sheet = scheduleDone.sheetPresentationController{
            sheet.detents = [.medium()]
            sheet.delegate = self
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = nil
        }
    }
}

//extension ScheduleStartViewController {
//    func Userdefualt(){
//        let request = AF.request(<#URLConvertible#>)
//    }
//}

