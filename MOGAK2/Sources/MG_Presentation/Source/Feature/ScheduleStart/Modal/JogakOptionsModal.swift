import SnapKit
import UIKit

final class JogakOptionsModal: UIViewController {
    var onCancel: (() -> Void)?
    var onEdit: (() -> Void)?

    private let jogakTitle: String

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFont.semibold20L140.value
        label.textColor = DesignSystemColor.black.value
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "조각의 내용을 수정하시겠어요?"
        label.textAlignment = .center
        label.font = DesignSystemFont.regular14L150.value
        label.textColor = DesignSystemColor.black.value.withAlphaComponent(0.6)
        return label
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(DesignSystemColor.signature.value, for: .normal)
        button.backgroundColor = DesignSystemColor.signatureBag.value
        button.titleLabel?.font = DesignSystemFont.medium16L100.value
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정하기", for: .normal)
        button.setTitleColor(DesignSystemColor.white.value, for: .normal)
        button.backgroundColor = DesignSystemColor.signature.value
        button.titleLabel?.font = DesignSystemFont.medium16L100.value
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, editButton])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()

    init(title: String) {
        jogakTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        titleLabel.text = jogakTitle
        configureLayout()
    }

    private func configureLayout() {
        view.addSubviews(titleLabel, subtitleLabel, buttonStack)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(49)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
    }

    @objc private func cancelButtonTapped() {
        onCancel?()
    }

    @objc private func editButtonTapped() {
        onEdit?()
    }
}
