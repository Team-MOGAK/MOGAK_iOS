import UIKit
import SnapKit

final class MG2OnBoardingFirstViewController: UIViewController {

    private let titleLabel = UILabel().then {
        $0.text = "되고 싶거나 이루고 싶은 \n목표를 설정해 \n의욕을 강화해보세요."
        $0.numberOfLines = 3
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = UIFont.pretendard(.medium, size: 28)
    }

    private let image = UIImageView().then {
        $0.image = UIImage(named: "onboarding1")
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
            if UIScreen.main.bounds.height < 670 {
                $0.top.equalTo(titleLabel.snp.bottom).offset(20)
                $0.size.equalTo(280)
            } else {
                $0.top.equalTo(titleLabel.snp.bottom).offset(64)
            }
            $0.centerX.equalToSuperview()
        }
    }
}
