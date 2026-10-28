import SnapKit
import UIKit

/// 오늘의 조각 한 줄 (PieceRow). 행 전체가 체크 영역이고 ⋯는 별도 메뉴.
/// 완료하면 `done-row` 바탕 · `faint` 취소선 (일부러 흐리게).
final class MG2JogakOccurrenceCell: UITableViewCell, MG2SkeletonBlockCell {
    static let reuseIdentifier = "MG2JogakOccurrenceCell"
    /// 행 사이 `space-stack`.
    static let rowSpacing = DS.Space.stack

    private let cardView = UIView()
    private let checkView = MG2CheckCircleView()
    private let titleLabel = UILabel()
    private let tagLabel = MG2TagLabel()
    private let detailLabel = UILabel()

    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)), for: .normal)
        button.tintColor = DS.Color.faint
        button.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        return button
    }()

    private var onMoreTapped: (() -> Void)?
    /// 스켈레톤은 행 사이 여백을 뺀 카드만 덮는다.
    var skeletonBlock: UIView { cardView }
    private var title = ""
    private var moak = DS.Moak.blue

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        cardView.roundCorners(DS.Radius.row)
        // `.md-piece-name` 16/21 600 한 줄 말줄임.
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontForContentSizeCategory = true
        // `.md-piece-meta` 12/16 600 sub. 좁으면 모각 태그가 먼저 줄어든다.
        detailLabel.apply(.caption1Semi, color: DS.Color.sub)
        tagLabel.setContentCompressionResistancePriority(.defaultHigh - 1, for: .horizontal)
        configureLayout()
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onMoreTapped = nil
    }

    func configure(item: MG2JogakOccurrenceItem, onMoreTapped: @escaping () -> Void) {
        title = item.title
        moak = DS.Moak.from(hex: item.color)
        tagLabel.configure(text: item.mogakTitle, moak: moak)
        detailLabel.text = item.detail
        self.onMoreTapped = onMoreTapped
        accessibilityCustomActions = [UIAccessibilityCustomAction(name: "더보기") { [weak self] _ in self?.onMoreTapped?(); return true }]
        setCompleted(item.isCompleted, animated: false)
    }

    func setCompleted(_ isCompleted: Bool, animated: Bool) {
        checkView.setDone(isCompleted, color: moak.deep, animated: animated)
        cardView.backgroundColor = isCompleted ? DS.Color.doneRow : DS.Color.surface
        var attributes = T.callout.attributes(color: isCompleted ? DS.Color.faint : DS.Color.ink)
        if isCompleted { attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue }
        titleLabel.attributedText = NSAttributedString(string: title, attributes: attributes)
        // 문단 스타일 기본값(줄바꿈)이 말줄임을 덮어써 글자가 잘리므로 attributedText 뒤에 다시 건다.
        titleLabel.lineBreakMode = .byTruncatingTail
        accessibilityLabel = "\(title), \(tagLabel.text ?? ""), \(detailLabel.text ?? "")"
        accessibilityValue = isCompleted ? "완료" : "미완료"
        accessibilityHint = isCompleted ? "두 번 탭하면 완료를 취소해요" : "두 번 탭하면 완료해요"
    }

    @objc private func moreButtonTapped() {
        onMoreTapped?()
    }

    /// `.md-piece`: padding 6 4 · gap 2 · 체크 48 · 본문 최소 56 · ⋯ 44.
    private func configureLayout() {
        let metaStack = UIStackView(arrangedSubviews: [tagLabel, detailLabel])
        metaStack.spacing = 6
        metaStack.alignment = .center
        let textStack = UIStackView(arrangedSubviews: [titleLabel, metaStack])
        textStack.axis = .vertical
        textStack.spacing = 5
        textStack.alignment = .leading

        let checkArea = UIView()
        checkArea.isUserInteractionEnabled = false
        contentView.addSubview(cardView)
        cardView.addSubviews(checkArea, textStack, moreButton)
        checkArea.addSubview(checkView)

        cardView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(Self.rowSpacing)
            $0.height.greaterThanOrEqualTo(DS.Size.row + 12)
        }
        checkArea.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(48)
        }
        checkView.snp.makeConstraints { $0.center.equalToSuperview() }
        // 큰 글자에서는 행이 세로로 늘어난다.
        textStack.snp.makeConstraints {
            $0.leading.equalTo(checkArea.snp.trailing).offset(2)
            $0.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().inset(6)
            $0.trailing.lessThanOrEqualTo(moreButton.snp.leading).offset(-2)
        }
        moreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(DS.Size.touch)
        }
    }
}
