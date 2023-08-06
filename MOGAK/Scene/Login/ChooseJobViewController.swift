//
//  ChooseJobViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/11.
//

import UIKit
import SnapKit

class ChooseJobViewController: UIViewController {
    
//    private var items = ["광고기획자", "개발자", "기업가", "고객관리", "기술자", "공무원", "나", "다", "라", "마", "바", "사", "자", "차", "카", "타", "파", "하"]
    private var items = ["기획/전략", "법무,사무,총무", "인사/HR", "회계/세무", "마케팅/광고/MD", "개발/데이터", "디자인", "물류/무역", "운전/운송/배송", "영업", "고객상담/TM", "금융/보험", "식/음료", "고객서비스/리테일", "엔지니어링/설계", "제조/생산", "교육", "건축/시설", "의료/바이오", "미디어/문화", "스포츠", "공공복지", "자영업", "군인", "의료", "회계사", "법무사", "노무사", "세무사", "관세사", "교사", "디지털노마드", "영상제작자", "크리에이터"]
    // 검색 결과를 담는 배열
    private var filteredItems: [String] = []
    // checkButton 선택 셀 index
    private var previousIndexPath: IndexPath?
    private var selectedIndexPath: IndexPath?
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = "희망/현직 직무 선택"
        label.textColor = .black
        label.font = UIFont.pretendard(.bold, size: 24)
        return label
    }()
    
    private let subLabel : UILabel = {
        let label = UILabel()
        label.text = "어떤 목표를 가진 모각러들과 함께 성장하고 싶으신가요?"
        label.textColor = UIColor(hex: "808497")
        label.font = UIFont.pretendard(.medium, size: 16)
        return label
    }()
    
    private lazy var searchBar : UISearchBar = {
        let search = UISearchBar()
        let placeholderAttributes = [NSAttributedString.Key.font: UIFont.pretendard(.bold, size: 16), NSAttributedString.Key.foregroundColor : UIColor(hex: "BFC3D4")]
        let placeholderText = "직무를 입력해주세요."
        search.delegate = self
        search.searchBarStyle = .minimal
        search.showsCancelButton = true
        search.searchTextField.backgroundColor = UIColor(hex: "EEF0F8")
        search.searchTextField.layer.cornerRadius = 10
        search.searchTextField.borderStyle = .none
        search.searchTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        search.searchTextField.textAlignment = .left
        return search
    }()
    
    private let tableView : UITableView = {
        let tableView = UITableView()
//        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var nextButton : UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.backgroundColor = UIColor(hex: "BFC3D4")
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(nextButtonIsClicked), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.configureNavBar()
        self.configureLabel()
        self.configureSearchBar()
        self.configureButton()
        self.configureTableView()
        
        self.reload()
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .gray
    }
    
    private func configureLabel() {
        self.view.addSubviews(titleLabel, subLabel)
        
        titleLabel.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(20)
        })
        
        subLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        })
    }
    
    private func configureSearchBar() {
        self.view.addSubview(searchBar)
        
        searchBar.snp.makeConstraints({
            $0.top.equalTo(subLabel.snp.bottom).offset(48)
            $0.leading.trailing.equalToSuperview().inset(20)
//            $0.height.equalTo(33)
            $0.height.equalToSuperview().multipliedBy(0.061)
        })
        
    }
    
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(NameCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints({
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.bottom.equalTo(nextButton.snp.top).offset(-12)
        })
    }
    
    private func reload() {
        self.tableView.reloadData()
    }
    
    private func configureButton() {
        self.view.addSubview(nextButton)
        
        nextButton.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
//            $0.height.equalTo(53)
            $0.height.equalToSuperview().multipliedBy(0.061)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-23)
        })
    }
    
    private func nextButtonIsOn() {
        nextButton.isUserInteractionEnabled = true
        nextButton.backgroundColor = UIColor(hex: "475FFD")
    }
    
    private func nextButtonIsOff() {
        nextButton.isUserInteractionEnabled = false
        nextButton.backgroundColor = UIColor(hex: "BFC3D4")
    }
    
    @objc private func nextButtonIsClicked() {
        if let _ = selectedIndexPath {
            let regionVC = ChooseRegionViewController()
            self.navigationController?.pushViewController(regionVC, animated: true)
        } else {
            let alert = UIAlertController(title: "경고", message: "직군을 선택하셔야 합니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "다시 돌아가기", style: .cancel))
            present(alert, animated: true)
        }
    }
}

extension ChooseJobViewController: UISearchBarDelegate {
    //외부 탭시 키보드 내림.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    // 리턴 키 입력 시 키보드 내림
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterItems(with: searchText)
        self.reload()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 취소 버튼을 누를 때 검색어를 초기화하고 테이블 뷰를 갱신합니다.
        searchBar.text = nil
        searchBar.resignFirstResponder() // 키보드 내림
        filterItems(with: "")
        self.reload()
    }
    
    private func filterItems(with searchText: String) {
        if searchText.isEmpty {
            filteredItems = items // 검색어가 비어있으면 모든 항목을 포함
        } else {
            filteredItems = items.filter { $0.range(of: searchText, options: .caseInsensitive) != nil }
            // 검색어를 기준으로 items 배열을 필터링하여 검색 결과를 filteredItems에 저장
        }
    }
    
}

extension ChooseJobViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionTitles = getSectionTitles()
        return sectionTitles.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filteredItemsInSection = getFilteredItemsInSection(section)
        return filteredItemsInSection.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NameCell
        
        let filteredItemsInSection = getFilteredItemsInSection(indexPath.section)
        
        let item = filteredItemsInSection[indexPath.row]
        cell.textLabel?.text = item
        cell.selectionStyle = .none
        if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath {
            cell.checkButton.setImage(UIImage(named: "checkOn"), for: .normal)
            nextButtonIsOn()
        } else {
            cell.checkButton.setImage(UIImage(named: "checkOff"), for: .normal)
            nextButtonIsOff()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexPath = selectedIndexPath  // 이전에 선택된 셀의 인덱스 저장
        selectedIndexPath = indexPath  // 선택된 셀의 인덱스 업데이트
        
        // 이전에 선택된 셀의 인덱스와 현재 선택한 셀의 인덱스가 같으면 체크 버튼을 숨깁니다.
        if previousIndexPath == indexPath {
            if let cell = tableView.cellForRow(at: indexPath) as? NameCell {
                cell.checkButton.setImage(UIImage(named: "checkOff"), for: .normal)
                nextButtonIsOff()
            }
            selectedIndexPath = nil  // 선택된 셀의 인덱스를 nil로 설정하여 선택 해제
        } else {
            // 이전에 선택된 셀의 인덱스와 현재 선택한 셀의 인덱스가 다르면 이전에 선택된 셀을 업데이트합니다.
            if let previousIndexPath = previousIndexPath, let cell = tableView.cellForRow(at: previousIndexPath) as? NameCell {
                cell.checkButton.setImage(UIImage(named: "checkOff"), for: .normal)
                nextButtonIsOn()
            }
            if let cell = tableView.cellForRow(at: indexPath) as? NameCell {
                cell.checkButton.setImage(UIImage(named: "checkOn"), for: .normal)
                nextButtonIsOn()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // 섹션 헤더에 표시할 문자열을 반환합니다.
        let sectionTitles = getSectionTitles()
        if section < sectionTitles.count {
            return sectionTitles[section]
        }
        return nil
    }
    
    private func searchBarIsEmpty() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    private func getSectionTitles() -> [String] {
        // 이름의 첫 글자로 이루어진 섹션 타이틀 배열을 반환합니다.
        let sectionTitles = items.map { name -> String in
            if let firstCharacter = name.first, let unicodeScalar = firstCharacter.unicodeScalars.first {
                let scalarValue = unicodeScalar.value
                if (0xAC00 <= scalarValue && scalarValue <= 0xD7A3) { // 첫 글자가 한글인 경우
                    let unicodeValue = scalarValue - 0xAC00
                    let choseongIndex = Int(unicodeValue / (21 * 28))
                    let choseong = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
                    let choseongCharacter = choseong[choseongIndex]
                    return choseongCharacter
                } else { // 첫 글자가 한글이 아닌 경우
                    return name.prefix(1).uppercased()
                }
            } else { // 이름이 비어있는 경우
                return ""
            }
        }
        
        let uniqueTitles = Array(Set(sectionTitles)).sorted()
        return uniqueTitles
    }
    
    private func getFilteredItemsInSection(_ section: Int) -> [String] {
        let sectionTitles = getSectionTitles()
        let sectionTitle = sectionTitles[section]
        
        let filteredItemsInSection: [String]
        if searchBarIsEmpty() {
            filteredItemsInSection = items.filter { item -> Bool in
                if let firstCharacter = item.first, let unicodeScalar = firstCharacter.unicodeScalars.first {
                    let scalarValue = unicodeScalar.value
                    if (0xAC00 <= scalarValue && scalarValue <= 0xD7A3) { // 첫 글자가 한글인 경우
                        let unicodeValue = scalarValue - 0xAC00
                        let choseongIndex = Int(unicodeValue / (21 * 28))
                        let choseong = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
                        let choseongCharacter = choseong[choseongIndex]
                        return "\(choseongCharacter)" == sectionTitle
                    } else { // 첫 글자가 한글이 아닌 경우
                        return item.prefix(1).uppercased() == sectionTitle
                    }
                } else { // 이름이 비어있는 경우
                    return sectionTitle.isEmpty
                }
            }
        } else {
            filteredItemsInSection = filteredItems.filter { item -> Bool in
                if let firstCharacter = item.first, let unicodeScalar = firstCharacter.unicodeScalars.first {
                    let scalarValue = unicodeScalar.value
                    if (0xAC00 <= scalarValue && scalarValue <= 0xD7A3) { // 첫 글자가 한글인 경우
                        let unicodeValue = scalarValue - 0xAC00
                        let choseongIndex = Int(unicodeValue / (21 * 28))
                        let choseong = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
                        let choseongCharacter = choseong[choseongIndex]
                        return "\(choseongCharacter)" == sectionTitle
                    } else { // 첫 글자가 한글이 아닌 경우
                        return item.prefix(1).uppercased() == sectionTitle
                    }
                } else { // 이름이 비어있는 경우
                    return sectionTitle.isEmpty
                }
            }
        }
        
        return filteredItemsInSection
    }
    
    
}
