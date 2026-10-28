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
        let imageName: String
        let imageLayout: ImageLayout

        static let all = [
            Page(title: "이루고 싶은\n최종 목표 하나를\n가운데 칸에 적어요", imageName: "onboarding1", imageLayout: .intrinsic),
            Page(title: "최종 목표를 둘러싼\n모각 8개를\n채워요", imageName: "onboarding2", imageLayout: .fill(topOffset: 32)),
            Page(title: "모각마다\n오늘 할 수 있는\n조각 8개를 정해요", imageName: "onboarding3", imageLayout: .fill(topOffset: 24)),
            Page(title: "조각이 오늘의 할 일로 올라오고\n체크할수록\n판의 칸이 차올라요", imageName: "onboarding4", imageLayout: .fill(topOffset: 24))
        ]
    }

    /// 온보딩 단계 제목 (T.onboardingTitle).
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.adjustsFontForContentSizeCategory = true
        $0.accessibilityTraits = .header
    }

    private let imageView = UIImageView()

    init(page: Page) {
        super.init(frame: .zero)
        backgroundColor = DS.Color.canvas
        titleLabel.attributedText = NSAttributedString(string: page.title, attributes: T.onboardingTitle.attributes(alignment: .center))
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
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }

        switch imageLayout {
        case .intrinsic:
            imageView.snp.makeConstraints {
                if (window?.windowScene?.screen ?? UIScreen.main).bounds.height < 670 {
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
