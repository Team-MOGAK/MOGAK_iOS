import SnapKit
import UIKit

final class JogakSimpleModalViewController: UIViewController {
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?

    private let viewData: MG2JogakSummaryViewData

    private lazy var categoryLabel: CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 4, bottom: 4, left: 10, right: 10)
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

        categoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.leading.equalToSuperview().offset(20)
        }

        jogakTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
        }

        routineStack.snp.makeConstraints { make in
            make.height.equalTo(viewData.isRoutine ? 24 : 0)
            make.top.equalTo(jogakTitleLabel.snp.bottom).offset(13)
            make.leading.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        termLabel.snp.makeConstraints { make in
            let anchor = viewData.isRoutine ? routineStack.snp.bottom : jogakTitleLabel.snp.bottom
            make.top.equalTo(anchor).offset(13)
            make.leading.equalToSuperview().offset(20)
        }

        termTimeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(termLabel)
        }

        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(termTimeLabel.snp.bottom).offset(viewData.isRoutine ? 6 : 15)
            make.height.equalTo(52)
            make.leading.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
    }

    @objc private func deleteButtonTapped() {
        onDelete?()
    }

    @objc private func editButtonTapped() {
        onEdit?()
    }
}
