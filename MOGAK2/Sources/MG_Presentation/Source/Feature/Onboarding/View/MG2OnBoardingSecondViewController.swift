import UIKit
import SnapKit

final class MG2OnBoardingSecondViewController: UIViewController {

    private let titleLabel = UILabel().then {
        $0.text = "만다라트 기법을 통해 \n목표를 달성하기 위한 \n세부 목표를 구체화하세요."
        $0.numberOfLines = 3
        $0.textColor = .black
        $0.font = UIFont.pretendard(.regular, size: 28)
        $0.textAlignment = .center
        $0.asFont(targetString: "만다라트 기법을 통해", font: UIFont.pretendard(.semiBold, size: 30))
    }

    private let image = UIImageView().then {
        $0.image = UIImage(named: "onboarding2")
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
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.bottom.equalToSuperview().offset(-10)
            $0.centerX.equalToSuperview()
        }
    }
}
