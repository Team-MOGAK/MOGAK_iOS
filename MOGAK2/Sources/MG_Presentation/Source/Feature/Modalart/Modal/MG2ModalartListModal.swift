//
//  MG2ModalartListModal.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/02.
//

import UIKit
import SnapKit

///모다라트 리스트 보여주는 모달
final class MG2ModalartListModal: UIViewController {
    private let modalarts: [MG2ModalartListItemEntity]
    var onSelection: ((Int) -> Void)?
    var onAdd: (() -> Void)?
    var onDismiss: (() -> Void)?

    /// 마지막 행은 "모다라트 추가"
    private var rowCount: Int {
        modalarts.count + 1
    }

    init(modalarts: [MG2ModalartListItemEntity]) {
        self.modalarts = modalarts
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

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureDimmedBackground()
        configureTableView()
    }

    // MARK: - 뒤에 투명한 배경 탭 설정
    private func configureDimmedBackground() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedBackgroundViewTapped))
        dimmedBackgroundView.addGestureRecognizer(dimmedTap)
        dimmedBackgroundView.isUserInteractionEnabled = true
    }

    // MARK: - 배경색 탭 했을 떄
    @objc private func dimmedBackgroundViewTapped() {
        onDismiss?()
    }

    // MARK: - tableview setting
    private func configureTableView() {
        modalArtListTableView.register(MG2ModalartListCell.self, forCellReuseIdentifier: MG2ModalartListCell.identifier)
        modalArtListTableView.delegate = self
        modalArtListTableView.dataSource = self
    }
}

extension MG2ModalartListModal {
    // MARK: - 뷰들 레이아웃 잡기
    private func configureLayout() {
        view.addSubviews(dimmedBackgroundView, mainView)
        mainView.addSubview(modalArtListTableView)

        dimmedBackgroundView.alpha = 0.7

        dimmedBackgroundView.snp.makeConstraints {
            $0.size.equalToSuperview()
        }

        mainView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(107)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(rowCount * 53)
        }

        modalArtListTableView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}

extension MG2ModalartListModal: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < modalarts.count {
            onSelection?(indexPath.row)
        } else {
            onAdd?()
        }
    }
}

extension MG2ModalartListModal: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = modalArtListTableView.dequeueReusableCell(withIdentifier: MG2ModalartListCell.identifier, for: indexPath) as? MG2ModalartListCell else { return UITableViewCell() }

        if indexPath.row == rowCount - 1 { //맨 마지막 데이터일 경우 선이 안보이도록 설정
            cell.separatorInset = UIEdgeInsets(top: 0, left: modalArtListTableView.bounds.size.width, bottom: 0, right: 0);
        }
        if indexPath.row < modalarts.count {
            let modalart = modalarts[indexPath.row]
            cell.configure(title: modalart.title, style: modalart.hasDefaultTitle ? .defaultTitle : .normal)
        } else {
            cell.configure(title: "모다라트 추가", style: .add)
        }
        return cell
    }
}
