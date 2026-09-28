import UIKit
import SnapKit
import Then

/// 온보딩 한 페이지. 문구와 이미지만 있는 화면 조각이라 ViewController가 아니라 View로 둔다.
final class MG2OnboardingPageView: UIView {
    struct Page {
        enum ImageLayout {
            /// 정사각형 이미지: 원본 크기, 작은 화면에서는 280으로 축소
            case intrinsic
            /// 세로로 긴 이미지: 제목 아래부터 화면 끝까지 맞춤
            case fill(topOffset: CGFloat)
        }

        let title: String
        let titleFont: UIFont
        let highlight: (text: String, font: UIFont)?
        let imageName: String
        let imageLayout: ImageLayout

        static let all = [
            Page(title: "되고 싶거나 이루고 싶은 \n목표를 설정해 \n의욕을 강화해보세요.", titleFont: UIFont.pretendard(.medium, size: 28), highlight: nil, imageName: "onboarding1", imageLayout: .intrinsic),
            Page(title: "만다라트 기법을 통해 \n목표를 달성하기 위한 \n세부 목표를 구체화하세요.", titleFont: UIFont.pretendard(.regular, size: 28), highlight: ("만다라트 기법을 통해", UIFont.pretendard(.semiBold, size: 30)), imageName: "onboarding2", imageLayout: .fill(topOffset: 32)),
            Page(title: "한 가지의 목표를 이루기 위한 \n8가지의 세부 목표를 \n설정하세요", titleFont: UIFont.pretendard(.regular, size: 28), highlight: ("8가지의 세부 목표를 \n설정하세요", UIFont.pretendard(.semiBold, size: 28)), imageName: "onboarding3", imageLayout: .fill(topOffset: 24)),
            Page(title: "세부 목표를 이루기 위한 \n세부 행동 8가지를 정하고, \n습관으로 만들어보세요", titleFont: UIFont.pretendard(.regular, size: 28), highlight: ("\n세부 행동 8가지를 정하고, \n습관으로 만들어보세요", UIFont.pretendard(.semiBold, size: 28)), imageName: "onboarding4", imageLayout: .fill(topOffset: 24))
        ]
    }

    private let titleLabel = UILabel().then {
        $0.numberOfLines = 3
        $0.textColor = .black
        $0.textAlignment = .center
    }

    private let imageView = UIImageView()

    init(page: Page) {
        super.init(frame: .zero)
        backgroundColor = DesignSystemColor.gray2.value
        titleLabel.text = page.title
        titleLabel.font = page.titleFont
        if let highlight = page.highlight {
            titleLabel.asFont(targetString: highlight.text, font: highlight.font)
        }
        imageView.image = UIImage(named: page.imageName)
        configureLayout(imageLayout: page.imageLayout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureLayout(imageLayout: Page.ImageLayout) {
        addSubviews(titleLabel, imageView)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(64)
            $0.centerX.equalToSuperview()
        }

        switch imageLayout {
        case .intrinsic:
            imageView.snp.makeConstraints {
                if UIScreen.main.bounds.height < 670 {
                    $0.top.equalTo(titleLabel.snp.bottom).offset(20)
                    $0.size.equalTo(280)
                } else {
                    $0.top.equalTo(titleLabel.snp.bottom).offset(64)
                }
                $0.centerX.equalToSuperview()
            }
        case .fill(let topOffset):
            imageView.contentMode = .scaleAspectFit
            imageView.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(topOffset)
                $0.bottom.equalToSuperview().offset(-10)
                $0.centerX.equalToSuperview()
            }
        }
    }
}
