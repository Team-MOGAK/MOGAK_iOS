import SnapKit
import UIKit

final class MG2JogakSimpleModal: UIViewController {
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?

    private let viewData: MG2JogakSummaryViewData

    private lazy var categoryLabel: MG2PaddingLabel = {
        let label = MG2PaddingLabel(top: 4, bottom: 4, left: 10, right: 10)
        label.font = DesignSystemFont.semibold14L150.value
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()

    private let jogakTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = DesignSystemFont.medium18L140.value
        return label
    }()

    private lazy var routineStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [routineLabel, routineDayLabel])
        stack.axis = .horizontal
        return stack
    }()

    private let routineLabel: UILabel = {
        let label = UILabel()
        label.text = "루틴지정"
        label.font = DesignSystemFont.semibold14L150.value
        return label
    }()

    private let routineDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemColor.gray5.value
        label.font = DesignSystemFont.regular16L150.value
        return label
    }()

    private let termLabel: UILabel = {
        let label = UILabel()
        label.text = "기간"
        label.textColor = DesignSystemColor.gray5.value
        label.font = DesignSystemFont.semibold14L150.value
        return label
    }()

    private let termTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemColor.gray5.value
        label.font = DesignSystemFont.regular16L150.value
        return label
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("삭제", for: .normal)
        button.backgroundColor = DesignSystemColor.signatureBag.value
        button.layer.cornerRadius = 10
        button.setTitleColor(DesignSystemColor.signature.value, for: .normal)
        button.titleLabel?.font = DesignSystemFont.medium16L100.value
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정", for: .normal)
        button.backgroundColor = DesignSystemColor.signature.value
        button.layer.cornerRadius = 10
        button.setTitleColor(DesignSystemColor.white.value, for: .normal)
        button.titleLabel?.font = DesignSystemFont.medium16L100.value
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [deleteButton, editButton])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()

    init(viewData: MG2JogakSummaryViewData) {
        self.viewData = viewData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureContent()
        configureLayout()
    }

    private func configureContent() {
        let categoryColor = UIColor(hex: viewData.categoryColor)
        categoryLabel.text = viewData.category
        categoryLabel.textColor = categoryColor
        categoryLabel.backgroundColor = categoryColor.withAlphaComponent(0.1)
        jogakTitleLabel.text = viewData.title
        routineStack.isHidden = !viewData.isRoutine
        routineDayLabel.text = viewData.routineDaysText
        termTimeLabel.text = viewData.periodText
    }

    private func configureLayout() {
        view.addSubviews(categoryLabel, jogakTitleLabel, routineStack, termLabel, termTimeLabel, buttonStack)

        categoryLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(44)
            $0.leading.equalToSuperview().offset(20)
        }

        jogakTitleLabel.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }

        routineStack.snp.makeConstraints {
            $0.height.equalTo(viewData.isRoutine ? 24 : 0)
            $0.top.equalTo(jogakTitleLabel.snp.bottom).offset(13)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }

        termLabel.snp.makeConstraints {
            let anchor = viewData.isRoutine ? routineStack.snp.bottom : jogakTitleLabel.snp.bottom
            $0.top.equalTo(anchor).offset(13)
            $0.leading.equalToSuperview().offset(20)
        }

        termTimeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(termLabel)
        }

        buttonStack.snp.makeConstraints {
            $0.top.equalTo(termTimeLabel.snp.bottom).offset(viewData.isRoutine ? 6 : 15)
            $0.height.equalTo(52)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
    }

    @objc private func deleteButtonTapped() {
        onDelete?()
    }

    @objc private func editButtonTapped() {
        onEdit?()
    }
}
