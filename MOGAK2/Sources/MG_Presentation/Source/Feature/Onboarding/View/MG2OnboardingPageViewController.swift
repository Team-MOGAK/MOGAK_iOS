import UIKit

struct MG2OnboardingPage {
    let imageName: String
    let title: String
    let subtitle: String
}

final class MG2OnboardingPageViewController: UIViewController {

    private let page: MG2OnboardingPage

    init(page: MG2OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystemColor.gray2.value

        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: page.imageName)

        titleLabel.text = page.title
        titleLabel.font = UIFont.pretendard(.bold, size: 24)
        titleLabel.textColor = DesignSystemColor.black.value
        titleLabel.textAlignment = .center

        subtitleLabel.text = page.subtitle
        subtitleLabel.font = UIFont.pretendard(.regular, size: 16)
        subtitleLabel.textColor = DesignSystemColor.gray4.value
        subtitleLabel.textAlignment = .center

        [imageView, titleLabel, subtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}
