import UIKit
import SnapKit

final class MG2OnBoardingThirdViewController: UIViewController {

    private let titleLabel = UILabel().then {
        $0.text = "한 가지의 목표를 이루기 위한 \n8가지의 세부 목표를 \n설정하세요"
        $0.numberOfLines = 3
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = UIFont.pretendard(.regular, size: 28)
        $0.asFont(targetString: "8가지의 세부 목표를 \n설정하세요", font: UIFont.pretendard(.semiBold, size: 28))
    }

    private let image = UIImageView().then {
        $0.image = UIImage(named: "onboarding3")
        $0.contentMode = .scaleAspectFit
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystemColor.gray2.value
        configure()
    }

    private func configure() {
        view.addSubview(titleLabel)
        view.addSubview(image)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(64)
            $0.centerX.equalToSuperview()
        }

        image.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.bottom.equalToSuperview().offset(-10)
            $0.centerX.equalToSuperview()
        }
    }
}
