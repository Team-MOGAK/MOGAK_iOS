import SnapKit
import UIKit

final class JogakOptionsModal: UIViewController {
    var onCancel: (() -> Void)?
    var onEdit: (() -> Void)?

    private let jogakTitle: String

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(.bold, size: 20)
        label.textColor = UIColor(hex: "24252E")
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "조각의 내용을 수정하시겠어요?"
        label.textAlignment = .center
        label.font = UIFont.pretendard(.regular, size: 14)
        label.textColor = UIColor(hex: "24252E").withAlphaComponent(0.6)
        return label
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(UIColor(hex: "475FFD"), for: .normal)
        button.backgroundColor = UIColor(hex: "E8EBFE")
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "475FFD")
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
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
        view.addSubviews(titleLabel, subtitleLabel, cancelButton, editButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(28)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        cancelButton.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(20)
            make.trailing.equalTo(view.snp.centerX).offset(-5)
            make.height.equalTo(52)
        }

        editButton.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.centerX).offset(5)
            make.trailing.bottom.equalToSuperview().inset(20)
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
