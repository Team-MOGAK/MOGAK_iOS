import SnapKit
import UIKit

final class MG2OnboardingViewController: UIViewController, UIScrollViewDelegate {
    var onFinish: (() -> Void)?

    private let viewModel: MG2OnboardingViewModel
    private let pageViews = MG2OnboardingPageView.Page.all.map(MG2OnboardingPageView.init(page:))

    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let startButton = MG2PrimaryActionButton()

    init(viewModel: MG2OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystemColor.gray2.value

        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self

        pageControl.numberOfPages = pageViews.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = DesignSystemColor.gray3.value
        pageControl.currentPageIndicatorTintColor = DesignSystemColor.signature.value
        pageControl.addTarget(self, action: #selector(pageControlChanged(_:)), for: .valueChanged)

        startButton.setTitle("시작하기", for: .normal)
        startButton.isEnabled = false
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)

        view.addSubviews(scrollView, pageControl, startButton)

        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(pageControl.snp.top).offset(-10)
        }
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(startButton.snp.top).offset(-18)
        }
        startButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            $0.height.equalTo(52)
        }

        configurePages()
    }

    private func configurePages() {
        var previous: UIView?

        for pageView in pageViews {
            scrollView.addSubview(pageView)
            pageView.snp.makeConstraints {
                $0.top.bottom.equalTo(scrollView.contentLayoutGuide)
                $0.width.height.equalTo(scrollView.frameLayoutGuide)
                if let previous {
                    $0.leading.equalTo(previous.snp.trailing)
                } else {
                    $0.leading.equalTo(scrollView.contentLayoutGuide)
                }
            }
            previous = pageView
        }

        previous?.snp.makeConstraints {
            $0.trailing.equalTo(scrollView.contentLayoutGuide)
        }
    }

    @objc private func pageControlChanged(_ sender: UIPageControl) {
        let offsetX = scrollView.frame.width * CGFloat(sender.currentPage)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        updateStartButton(page: sender.currentPage)
    }

    @objc private func startButtonTapped() {
        viewModel.completeOnboarding()
        onFinish?()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(floor(scrollView.contentOffset.x / max(scrollView.frame.width, 1)))
        pageControl.currentPage = max(0, min(page, pageViews.count - 1))
        updateStartButton(page: pageControl.currentPage)
    }

    private func updateStartButton(page: Int) {
        startButton.isEnabled = viewModel.canStart(onPage: page)
    }
}
