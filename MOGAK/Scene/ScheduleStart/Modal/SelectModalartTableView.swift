import Foundation
import UIKit
import SnapKit
import Then
import Alamofire

class SelectModalartTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - 모다라트 정보
    
    var modalartList: [ScheduleModalartList] = []
    let Apinetwork =  ApiNetwork.shared
    
    //MARK: - 모다라트 구조체
    
    struct ModalartInfo {
        var ModalartTitle: String
        var ModalartId: Int
        //var ModalartColor : String
    }

    var ModalClosure : (() -> (Void))?
    
    //MARK: - 기본 프로퍼티
    
    private lazy var mainLabel: UIButton = {
        let btn = UIButton()
        btn.setTitle("내 모다라트", for: .normal)
        btn.titleLabel?.font = DesignSystemFont.semibold20L140.value
        btn.setTitleColor(.black, for: .normal)
        btn.isUserInteractionEnabled = true
        //btn.addTarget(self, action: #selector(tapModalart), for: .touchUpInside)
        return btn
    }()
    
    lazy var ModalartTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        SetUI()
        tableUI()
        getModalart()
    }
    
    //MARK: - SetUI
    
    func SetUI() {
        view.addSubviews(mainLabel,contentView)
        contentView.addSubviews(ModalartTableView)
        
        mainLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(36)
        }
        
        contentView.snp.makeConstraints{
            $0.top.equalTo(mainLabel.snp.bottom).offset(24)
            $0.leading.trailing.bottom.equalToSuperview()
            
        }
        ModalartTableView.snp.makeConstraints{
            $0.edges.equalTo(contentView)
            
        }
    }
    
    var ModalartData = [ModalartInfo]()
    
    func tableUI() {
        ModalartTableView.register(SelectModalartTableViewCell.self, forCellReuseIdentifier: "SelectModalartTableViewCell")
        ModalartTableView.dataSource = self
        ModalartTableView.delegate = self
        ModalartTableView.separatorStyle = .none
    }
    
    //MARK: - 모다라트 리스트 조회
    
    func getModalart() {
        Apinetwork.getModalartList { result in
            switch result {
            case .failure(let error):
                print("\(error.localizedDescription)")
            case .success(let data):
                print(data as Any)
                if let ModalartArray = data {
                    self.modalartList = ModalartArray
                    self.ModalartData = ModalartArray.map { Modalart in
                        return ModalartInfo(ModalartTitle: Modalart.title, ModalartId: Modalart.id)
                    }
                    self.ModalartTableView.reloadData()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ModalartData.count
 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectModalartTableViewCell", for: indexPath) as? SelectModalartTableViewCell else {
            return UITableViewCell()
        }
        
        let modalart = ModalartData[indexPath.section]
        cell.configureModalart(with: modalart)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(ModalartData[indexPath.section])
        
        
        
        }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 60
        }else {
            return 40
        }
        
    }
}

//MARK: - Cell
class SelectModalartTableViewCell: UITableViewCell {
    
    private lazy var ModalartLabel: CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 12, bottom: 12, left: 20, right: 20)
        label.font = DesignSystemFont.medium16L150.value
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var ModalartView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var ModalartStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ModalartView])
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.backgroundColor = .white
        return stackView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutModalart()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func layoutModalart() {
        contentView.addSubviews(ModalartStackView)
        ModalartView.addSubview(ModalartLabel)
        
        ModalartStackView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        ModalartView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.bottom.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
        
        ModalartLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalTo(ModalartStackView)
        }
    }
    
    func configureModalart(with ModalartData: SelectModalartTableView.ModalartInfo) {
        
        ModalartLabel.text = ModalartData.ModalartTitle
        ModalartLabel.textColor = DesignSystemColor.signature.value
        ModalartLabel.backgroundColor = DesignSystemColor.signature.value.withAlphaComponent(0.1)
    }
}
