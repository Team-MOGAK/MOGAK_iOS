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
        //let cell = tableView.dequeueReusableCell(withIdentifier: "LocationFilterTableViewCell", for: indexPath) as! LocationFilterTableViewCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationFilterTableViewCell") as? LocationFilterTableViewCell else {return UITableViewCell()}
        
        let target = dataSource[indexPath.row]
        
        cell.locationLabel.text = "\(target.location)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    // cell 클릭 시 이벤트(콘솔 출력)
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let target = dataSource[indexPath.row]
            print("\(target.location)")
        }
    
    lazy var tableView: UITableView = {
       let view = UITableView()
        view.register(LocationFilterTableViewCell.self, forCellReuseIdentifier: "LocationFilterTableViewCell")
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    var dataSource = Locations.data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        //tableView.register(UINib(nibName: "LocationFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationFilterTableViewCell")
        
        setupSheet()
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.snp.makeConstraints({
            $0.top.equalTo(view.snp.top).offset(80)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.bottom.equalTo(view.snp.bottom).offset(14)
        })
        
        
    }
    
    private func setupSheet() {
            //isModalInPresentation = true : sheet가 dismiss되지 않음!!! default는 false
            
            if let sheet = sheetPresentationController {
                /// 드래그 멈추면 그 위치에 멈추는 지점: default는 large()
                //sheet.detents = [.medium(), .large()]
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom { context in
                        return context.maximumDetentValue * 0.8
                    }
                    ]
                } else {
                    // Fallback on earlier versions
                }
                /// 초기화 드래그 위치
                sheet.selectedDetentIdentifier = .medium
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

