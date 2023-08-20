//
//  LocationFilterSheetView.swift
//  MOGAK
//
//  Created by 이재혁 on 2023/07/28.
//

import UIKit
import SnapKit

class LocationFilterSheetView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationFilterTableViewCell") as? LocationFilterTableViewCell else {return UITableViewCell()}
        
        let target = dataSource[indexPath.row]
        cell.locationLabel.text = "\(target.location)"
        
        if tableView.indexPathsForSelectedRows?.contains(indexPath) == true {
            cell.selectButton.setImage(UIImage(named: "MOGAK_button_filled"), for: .normal)
        } else {
            cell.selectButton.setImage(UIImage(named: "MOGAK_button"), for: .normal)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    // cell 클릭 시 이벤트
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let target = dataSource[indexPath.row]
        print("\(target.location) 선택함")
        
        // Deselect any previously selected rows
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for selectedIndexPath in selectedIndexPaths {
                if selectedIndexPath != indexPath {
                    tableView.deselectRow(at: selectedIndexPath, animated: true)
                }
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? LocationFilterTableViewCell {
            cell.selectButton.setImage(UIImage(named: "MOGAK_button_filled"), for: .disabled)
            cell.selectionStyle = .none
        }
        
        selectButton.isEnabled = true
        selectButton.backgroundColor = UIColor(hex: "475FFD")
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 선택 해제
        if let cell = tableView.cellForRow(at: indexPath) as? LocationFilterTableViewCell {
            cell.selectButton.setImage(UIImage(named: "MOGAK_button"), for: .disabled)
        }

        let target = dataSource[indexPath.row]
        print("\(target.location) 선택 해제함")
    }
    
    lazy var tableView: UITableView = {
       let view = UITableView()
        view.register(LocationFilterTableViewCell.self, forCellReuseIdentifier: "LocationFilterTableViewCell")
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
  
    
    private let selectButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        button.setTitle("선택 완료", for: .normal)
        button.setTitleColor(UIColor(hex: "FFFFFF"), for: .normal)
        //button.tintColor = UIColor(hex: "BFC3D4") // disabled color
        button.backgroundColor = UIColor(hex: "BFC3D4")
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 141, bottom: 15, right: 142)
        button.isEnabled = false
        return button
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "지역"
        label.font = UIFont.pretendard(.semiBold, size: 14)
        label.textColor = UIColor(hex: "24252E")
        
        return label
    }()
    
    var dataSource = Locations.data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        //tableView.register(UINib(nibName: "LocationFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationFilterTableViewCell")
        
        selectButton.addTarget(self, action: #selector(selectLocationButtonTapped), for: .touchUpInside)
        
        setupSheet()
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.snp.makeConstraints({
            $0.top.equalTo(view.snp.top).offset(30)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.bottom.equalTo(view.snp.bottom).offset(14)
        })
        
//        view.addSubview(selectButton)
//        selectButton.snp.makeConstraints({
//            $0.top.equalTo(tableView.snp.bottom).offset(15)
//            $0.horizontalEdges.equalToSuperview()
//            $0.bottom.equalToSuperview().offset(24)
//        })
        
        let headerView = UIView()
        headerView.backgroundColor = .white
        headerView.frame.size.height = 25
        
        headerView.addSubview(locationLabel)
        locationLabel.snp.makeConstraints({
            $0.width.equalTo(25)
            $0.height.equalTo(21)
            $0.centerY.equalToSuperview()
        })
        
        
        let footerView = UIView()
        footerView.backgroundColor = .white
        footerView.frame.size.height = 65
        
        footerView.addSubview(selectButton)
        selectButton.snp.makeConstraints({
            $0.width.equalTo(350)
            $0.height.equalTo(48)
            $0.center.equalToSuperview()
        })
        
        self.tableView.tableFooterView = footerView
        self.tableView.tableHeaderView = headerView
    }
    
    @objc func selectLocationButtonTapped() {
        // Dismiss the vc
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupSheet() {
            //isModalInPresentation = true : sheet가 dismiss되지 않음!!! default는 false
            
            if let sheet = sheetPresentationController {
                /// 드래그 멈추면 그 위치에 멈추는 지점: default는 large()
                //sheet.detents = [.medium(), .large()]
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom { context in
                        return context.maximumDetentValue * 0.9
                    }
                    ]
                } else {
                    // Fallback on earlier versions
                }
                /// 초기화 드래그 위치
                sheet.selectedDetentIdentifier = .large
                /// sheet
                //sheet.largestUndimmedDetentIdentifier = .medium -> 이게 배경색 흐려지게 하는거였다.. 왜그런진 모르겠다
                ///
                sheet.prefersGrabberVisible = true
                ///
                sheet.delegate = self
                ///
                sheet.presentingViewController.navigationController?.setNavigationBarHidden(true, animated: false)
                //sheet.presentingViewController.navigationController?.isNavigationBarHidden = true

            }
        }
}

