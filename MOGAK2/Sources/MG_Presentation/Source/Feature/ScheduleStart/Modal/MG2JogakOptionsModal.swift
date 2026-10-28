import SnapKit
import UIKit

/// 오늘의 조각 ⋯ 메뉴 시트.
final class MG2JogakOptionsModal: UIViewController {
    var onCancel: (() -> Void)?
    var onEdit: (() -> Void)?

    private let jogakTitle: String

    init(title: String) {
        jogakTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface

        let header = MG2SheetHeaderView(title: "‘\(jogakTitle)’")
        header.onClose = { [weak self] in self?.onCancel?() }
        let subtitleLabel = UILabel()
        subtitleLabel.apply(.paragraph, color: DS.Color.sub)
        subtitleLabel.text = "조각 이름이나 반복을 바꿀 수 있어요"
        subtitleLabel.textAlignment = .center
        let editButton = MG2PrimaryActionButton()
        editButton.setTitle("조각 수정", for: .normal)
        editButton.addAction(UIAction { [weak self] _ in self?.onEdit?() }, for: .touchUpInside)

        view.addSubviews(header, subtitleLabel, editButton)
        header.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        editButton.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.height.equalTo(DS.Size.button)
        }
    }
}
