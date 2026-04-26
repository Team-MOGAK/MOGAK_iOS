import UIKit

final class MG2OnboardingContainerViewController: UIViewController, UIScrollViewDelegate {

    private let viewModel: MG2OnboardingViewModel
    var onFinish: (() -> Void)?

    init(viewModel: MG2OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let startButton = MG2PrimaryActionButton()
    private var viewControllers: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystemColor.gray2.value

        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self

        pageControl.numberOfPages = viewModel.pageCount
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = DesignSystemColor.gray3.value
        pageControl.currentPageIndicatorTintColor = DesignSystemColor.signature.value
        pageControl.addTarget(self, action: #selector(pageControlChanged(_:)), for: .valueChanged)

        startButton.setTitle("시작하기", for: .normal)
        startButton.backgroundColor = DesignSystemColor.gray3.value
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        [scrollView, pageControl, startButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -108),

            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            startButton.heightAnchor.constraint(equalToConstant: 52)
        ])

        setupViewControllers()
        layoutPages()
    }

    private func setupViewControllers() {
        viewControllers = [
            MG2OnBoardingFirstViewController(),
            MG2OnBoardingSecondViewController(),
            MG2OnBoardingThirdViewController(),
            MG2OnBoardingForthViewController()
        ]
    }

    private func layoutPages() {
        var previous: UIView?

        for viewController in viewControllers {
            addChild(viewController)
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(viewController.view)
            viewController.didMove(toParent: self)

            NSLayoutConstraint.activate([
                viewController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
                viewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                viewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
                viewController.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
                viewController.view.leadingAnchor.constraint(equalTo: previous?.trailingAnchor ?? scrollView.leadingAnchor)
            ])
            previous = viewController.view
        }

        previous?.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    }

    @objc private func pageControlChanged(_ sender: UIPageControl) {
        let offsetX = scrollView.frame.width * CGFloat(sender.currentPage)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        updateButtonState(page: sender.currentPage)
    }

    @objc private func startTapped() {
        if pageControl.currentPage >= viewModel.startEnabledFromPage {
            onFinish?()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(floor(scrollView.contentOffset.x / max(scrollView.frame.width, 1)))
        pageControl.currentPage = max(0, min(page, viewModel.lastPageIndex))
        updateButtonState(page: pageControl.currentPage)
    }

    private func updateButtonState(page: Int) {
        startButton.backgroundColor = page >= viewModel.startEnabledFromPage ? DesignSystemColor.signature.value : DesignSystemColor.gray3.value
    }
}
