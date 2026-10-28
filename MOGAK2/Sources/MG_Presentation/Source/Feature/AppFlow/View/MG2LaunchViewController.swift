import SnapKit
import Then
import UIKit

/// 런치 스크린과 같은 로고를 띄워 두고 서버가 깨어나길 기다린다.
final class MG2LaunchViewController: UIViewController {
    weak var coordinator: MG2AppFlowCoordinator?

    private let viewModel: MG2LaunchViewModel

    private let logoImageView = UIImageView(image: UIImage(named: "Logo")).then {
        $0.contentMode = .scaleAspectFit
    }

    private let activityIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.color = DS.Color.accent
        $0.hidesWhenStopped = true
    }

    /// 설명 문구 (paragraph 15/22 · `sub`). 두 줄이라 줄 높이까지 맞춘다.
    private let statusLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.adjustsFontForContentSizeCategory = true
    }

    private lazy var retryButton = MG2PrimaryActionButton().then {
        $0.setTitle("다시 시도", for: .normal)
        $0.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    }

    init(viewModel: MG2LaunchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface
        configureLayout()
        viewModel.onStateChange = { [weak self] in self?.handle($0) }
        viewModel.start()
    }

    private func configureLayout() {
        view.addSubviews(logoImageView, activityIndicator, statusLabel, retryButton)

        logoImageView.snp.makeConstraints {
            $0.width.equalTo(179)
            $0.height.equalTo(109)
            $0.center.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(activityIndicator.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
        }
        retryButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
            $0.height.equalTo(DS.Size.button)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }

    private func handle(_ state: MG2LaunchViewModel.State) {
        switch state {
        case .waiting:
            setStatus(nil)
            retryButton.isHidden = true
        case .preparing:
            activityIndicator.startAnimating()
            setStatus("잠시만 기다려 주세요")
        case .failed:
            activityIndicator.stopAnimating()
            setStatus("연결이 원활하지 않아요\n잠시 후 다시 시도해 주세요")
            retryButton.isHidden = false
        case .ready:
            activityIndicator.stopAnimating()
            setStatus(nil)
            coordinator?.finishLaunch()
        }
    }

    private func setStatus(_ text: String?) {
        statusLabel.attributedText = text.map { NSAttributedString(string: $0, attributes: T.paragraph.attributes(color: DS.Color.sub, alignment: .center)) }
    }

    @objc private func retryButtonTapped() {
        viewModel.start()
    }
}
