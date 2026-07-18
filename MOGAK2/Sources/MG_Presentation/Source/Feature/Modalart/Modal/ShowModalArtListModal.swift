//
//  ShowModalArtListModal.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/02.
//

import UIKit
import SnapKit

///모다라트 리스트 보여주는 모달
final class ShowModalArtListModal: UIViewController {
    private let modalarts: [MG2ModalartListItemEntity]
    private let includesAddAction: Bool
    var onSelection: ((MG2ModalartListItemEntity, Int) -> Void)?
    var onAdd: (() -> Void)?
    var onDismiss: (() -> Void)?

    private var rowCount: Int {
        modalarts.count + (includesAddAction ? 1 : 0)
    }

    init(
        modalarts: [MG2ModalartListItemEntity],
        includesAddAction: Bool = false
    ) {
        self.modalarts = modalarts
        self.includesAddAction = includesAddAction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var dimmedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        return view
    }()
    
    private var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemColor.white.value
        view.layer.cornerRadius = 15
        
        return view
    }()
    
    private let modalArtListTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 15
        return tableView
    }()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        dimmedBackGroundSetting()
        setUpTableView()
    }
    
    //MARK: - 뒤에 투명한 배경 탭 설정
    private func dimmedBackGroundSetting() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmendBackgroundViewTapped(_:)))
        dimmedBackgroundView.addGestureRecognizer(dimmedTap)
        dimmedBackgroundView.isUserInteractionEnabled = true
    }
    
    //MARK: - 배경색 탭 했을 떄
    @objc private func dimmendBackgroundViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        onDismiss?()
    }
    
    //MARK: - tableview setting
    private func setUpTableView() {
        modalArtListTableView.register(ShowModalArtListCell.self, forCellReuseIdentifier: ShowModalArtListCell.identifier)
        modalArtListTableView.delegate = self
        modalArtListTableView.dataSource = self
    }
    
}

extension ShowModalArtListModal {
    //MARK: - 뷰들 레이아웃 잡기
    private func configureLayout() {
        self.view.addSubviews(dimmedBackgroundView, mainView)
        self.mainView.addSubview(modalArtListTableView)
        
        dimmedBackgroundView.alpha = 0.7
        
        dimmedBackgroundView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        
        mainView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(107)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(rowCount * 53)
        }
        
        modalArtListTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
    }
}

extension ShowModalArtListModal: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < modalarts.count {
            onSelection?(modalarts[indexPath.row], indexPath.row)
        } else {
            onAdd?()
        }
    }

}

extension ShowModalArtListModal: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = modalArtListTableView.dequeueReusableCell(withIdentifier: ShowModalArtListCell.identifier, for: indexPath) as? ShowModalArtListCell else { return UITableViewCell() }
        
        if indexPath.row == rowCount - 1 { //맨 마지막 데이터일 경우 선이 안보이도록 설정
            cell.separatorInset = UIEdgeInsets(top: 0, left: modalArtListTableView.bounds.size.width, bottom: 0, right: 0);
        }
        let title = indexPath.row < modalarts.count
            ? modalarts[indexPath.row].title
            : "모다라트 추가"
        cell.configure(name: title)
        return cell
    }
    
    
}
