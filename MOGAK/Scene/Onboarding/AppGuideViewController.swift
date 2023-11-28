//
//  AppGuideViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/09.
//

import UIKit
import Then

class AppGuideViewController: UIViewController {
    // 하단 버튼 클릭 시 페이지 이동을 위한 index
    private var buttonPageIndex = 0
    
    private let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)).with {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.bounces = false
    }
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        return pageControl
    }()
    
    private lazy var nextButton : UIButton = {
        let button = UIButton()
        button.setTitle("시작하기", for: .normal)
        button.backgroundColor = DesignSystemColor.gray3.value
        button.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(startButtonIsClikced), for: .touchUpInside)
        return button
    }()
    
    private let pageCount = 4
    private var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor.white
        self.view.backgroundColor = DesignSystemColor.gray2.value
        
        self.scrollView.delegate = self

        self.setupViews()
        self.setupViewControllers()
        self.setupAutoLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupViews() {
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(pageControl)
        self.view.addSubview(scrollView)
        self.view.addSubview(nextButton)
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = 4
        pageControl.pageIndicatorTintColor = DesignSystemColor.gray3.value
        pageControl.currentPageIndicatorTintColor = DesignSystemColor.signature.value
    }
    
    private func setupAutoLayout() {
        
        NSLayoutConstraint.activate([
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -108),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: self.view.frame.width * CGFloat(pageCount)),
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.7),
            
            
            
            nextButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            nextButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.061)
        ])
        
        var previousView: UIView?
        
        for viewController in viewControllers {
            
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(viewController.view)
            
            NSLayoutConstraint.activate([
                viewController.view.leadingAnchor.constraint(equalTo: previousView?.trailingAnchor ?? scrollView.leadingAnchor),
                viewController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
                viewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                viewController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                viewController.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])
            
            previousView = viewController.view
        }
        
        if let lastView = viewControllers.last?.view {
            lastView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        }
    }
    
    private func setupViewControllers() {
        for index in 0..<pageCount {
            let viewController = getContentViewController(index: index)
            viewControllers.append(viewController)
        }
    }
    
    private func getContentViewController(index: Int) -> UIViewController {
        switch index {
        case 0:
            return OnBoardingFirstViewController()
        case 1:
            return OnBoardingSecondViewController()
        case 2:
            return OnBoardingThirdViewController()
        case 3:
            return OnBoardingForthViewController()
        default:
            return UIViewController()
        }
    }
    
    @objc private func pageControlValueChanged(_ sender: UIPageControl) {
        let pageIndex = sender.currentPage
        
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width * CGFloat(pageIndex), y: 0), animated: true)
    }
    
    @objc private func startButtonIsClikced() {
        print(#fileID, #function, #line, "- 현재 페이지:\(pageControl.currentPage)")
        if pageControl.currentPage >= 2 {
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .overFullScreen
            self.present(loginVC, animated: true)
        }
    }
    
}

extension AppGuideViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
        pageControl.currentPage = pageIndex

//        if pageIndex != 0 {
//            self.view.backgroundColor = DesignSystemColor.gray.value
//        } else {
//            self.view.backgroundColor = UIColor.white
//        }
        
        if pageIndex >= 2 {
            nextButton.setTitle("시작하기", for: .normal)
            nextButton.backgroundColor = DesignSystemColor.signature.value
        } else {
            nextButton.setTitle("시작하기", for: .disabled)
            nextButton.backgroundColor = DesignSystemColor.gray3.value
        }

    }
    
}


#if DEBUG
import SwiftUI
struct Preview5: UIViewControllerRepresentable {
    
    // 여기 ViewController를 변경해주세요
    func makeUIViewController(context: Context) -> UIViewController {
        AppGuideViewController()
    }
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
}

struct AppGuideViewController_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            Preview5()
                .edgesIgnoringSafeArea(.all)
                .previewDisplayName("Preview")
        }
    }
}
#endif
