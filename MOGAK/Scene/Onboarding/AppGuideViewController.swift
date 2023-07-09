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
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        return pageControl
    }()
    
    private let skipLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(.regular, size: 14)
        label.text = "건너뛰기"
        return label
    }()
    
    private lazy var skipButton : UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(skipButtonIsClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton : UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(nextButtonIsClikced), for: .touchUpInside)
        return button
    }()
    
    private let pageCount = 3
    private var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "f9f9f9")
        
        self.scrollView.delegate = self
        
        self.setupViews()
        self.setupViewControllers()
        self.setupAutoLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setupViews() {
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        skipLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(skipLabel)
        self.view.addSubview(pageControl)
        self.view.addSubview(scrollView)
        self.view.addSubview(nextButton)
        self.view.addSubview(skipButton)
        
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = 3
        pageControl.pageIndicatorTintColor = UIColor(hex: "eaeaea")
        pageControl.currentPageIndicatorTintColor = UIColor(hex: "90bdff")
        
        scrollView.frame = UIScreen.main.bounds
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(pageCount), height: UIScreen.main.bounds.height)
        
        scrollView.alwaysBounceVertical = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
    }
    
    private func setupAutoLayout() {
        NSLayoutConstraint.activate([
            
            skipLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 21),
            
            skipButton.centerXAnchor.constraint(equalTo: skipLabel.centerXAnchor),
            skipButton.centerYAnchor.constraint(equalTo: skipLabel.centerYAnchor),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 20),
            scrollView.bottomAnchor.constraint(equalTo: nextButton.topAnchor),
            
            nextButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 53),
        ])
        
        var previousView: UIView?
        
        for viewController in viewControllers {
            
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(viewController.view)
            
            NSLayoutConstraint.activate([
                viewController.view.leadingAnchor.constraint(equalTo: previousView?.trailingAnchor ?? scrollView.leadingAnchor),
                viewController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
                viewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                viewController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
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
            return ViewController1()
        case 1:
            return ViewController2()
        case 2:
            return ViewController3()
        default:
            return UIViewController()
        }
    }
    
    @objc private func pageControlValueChanged(_ sender: UIPageControl) {
        let pageIndex = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width * CGFloat(pageIndex), y: 0), animated: true)
    }
    
    @objc private func nextButtonIsClikced() {
        let nextPageIndex = buttonPageIndex + 1
        
        if nextPageIndex >= pageCount {
            let loginVC = LoginViewController()
            self.navigationController?.pushViewController(loginVC, animated: true)
        } else {
            let contentOffsetX = scrollView.frame.width * CGFloat(nextPageIndex)
            scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: true)
        }
    }
    
    @objc private func skipButtonIsClicked() {
        let loginVC = LoginViewController()
        self.navigationController?.pushViewController(loginVC, animated: true)
        
    }
    
}

extension AppGuideViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
        pageControl.currentPage = pageIndex
        if pageIndex == 2 {
            nextButton.setTitle("시작하기", for: .normal)
        } else {
            nextButton.setTitle("다음", for: .normal)
        }
        buttonPageIndex = pageIndex
    }
}
