import SnapKit
import UIKit

/// 조각 시트: 태그 · 이름 · 반복 · 기간, 주 버튼 "조각 수정", 아래 `danger` "조각 삭제".
final class MG2JogakSimpleModal: UIViewController {
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?
    var onClose: (() -> Void)?

    private let viewData: MG2JogakSummaryViewData

    init(viewData: MG2JogakSummaryViewData) {
        self.viewData = viewData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface

        let header = MG2SheetHeaderView(title: "조각")
        header.onClose = { [weak self] in self?.onClose?() }
        let tag = MG2TagLabel()
        tag.configure(text: viewData.category, moak: DS.Moak.from(hex: viewData.categoryColor))
        let titleLabel = UILabel()
        titleLabel.apply(.title2)
        titleLabel.numberOfLines = 0
        titleLabel.text = viewData.title

        let info = UIStackView(arrangedSubviews: [
            infoRow(label: "반복", value: viewData.isRoutine ? "루틴 · \(viewData.routineDaysText)" : "오늘만"),
            infoRow(label: "기간", value: viewData.periodText)
        ])
        info.axis = .vertical
        info.spacing = 0
        info.backgroundColor = DS.Color.listTile
        info.roundCorners(DS.Radius.field)
        info.isLayoutMarginsRelativeArrangement = true
        info.layoutMargins = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)

        let editButton = MG2PrimaryActionButton()
        editButton.setTitle("조각 수정", for: .normal)
        editButton.addAction(UIAction { [weak self] _ in self?.onEdit?() }, for: .touchUpInside)
        let deleteButton = MG2PrimaryActionButton(style: .danger)
        deleteButton.setTitle("조각 삭제", for: .normal)
        deleteButton.addAction(UIAction { [weak self] _ in self?.onDelete?() }, for: .touchUpInside)

        view.addSubviews(header, tag, titleLabel, info, editButton, deleteButton)
        header.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        tag.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom).offset(14)
            $0.leading.equalToSuperview().inset(DS.Space.sheet)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(tag.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        info.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        editButton.snp.makeConstraints {
            $0.top.equalTo(info.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.height.equalTo(DS.Size.button)
        }
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(DS.Size.touch)
            $0.bottom.lessThanOrEqualToSuperview().inset(DS.Space.sheet)
        }
    }

    private func infoRow(label: String, value: String) -> UIView {
        let name = UILabel()
        name.apply(.footnoteBold, color: DS.Color.ink3)
        name.text = label
        let detail = UILabel()
        detail.apply(.footnote, color: DS.Color.sub)
        detail.text = value
        detail.textAlignment = .right
        detail.numberOfLines = 0
        let row = UIStackView(arrangedSubviews: [name, detail])
        row.spacing = 12
        row.snp.makeConstraints { $0.height.greaterThanOrEqualTo(DS.Size.touch) }
        name.setContentHuggingPriority(.required, for: .horizontal)
        name.setContentCompressionResistancePriority(.required, for: .horizontal)
        row.isAccessibilityElement = true
        row.accessibilityLabel = "\(label), \(value)"
        return row
    }
}
