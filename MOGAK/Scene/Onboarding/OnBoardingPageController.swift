//
//  OnBoardingPageController.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/27.
//

import Foundation
import UIKit
import SnapKit

class OnBoardingPageController: UIViewController {
    let pageViewController: UIPageViewController
    var pages = [UIViewController]()
    var currentVC: UIViewController {
        didSet {
            
        }
    }
    
    private lazy var startButton : UIButton = {
        let button = UIButton()
        button.setTitle("시작하기", for: .normal)
        button.backgroundColor = UIColor(hex: "475FFD")
        button.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        button.layer.cornerRadius = 10
//        button.addTarget(self, action: #selector(nextButtonIsClikced), for: .touchUpInside)
        return button
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        let page1 = OnBoardingFirstViewController()
        let page2 = OnBoardingSecondViewController()
        let page3 = OnBoardingThirdViewController()
        let page4 = OnBoardingForthViewController()
        
        pages.append(page1)
        pages.append(page2)
        pages.append(page3)
        pages.append(page4)
        
        currentVC = pages.first!
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = DesignSystemColor.gray.value
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        view.addSubview(startButton)
        pageViewController.didMove(toParent: self)
        
        pageViewController.dataSource = self
        
        view.snp.makeConstraints { make in
            make.top.equalTo(pageViewController.view.snp.top)
            make.left.equalTo(pageViewController.view.snp.left)
            make.bottom.equalTo(pageViewController.view.snp.bottom).offset(-200)
            make.right.equalTo(pageViewController.view.snp.right)
        }
        
//        startButton.snp.makeConstraints { make in
//            make.bottom.equalToSuperview().offset(10)
//            make.leading.equalToSuperview()
//            make.centerX.equalToSuperview()
//        }

        pageViewController.setViewControllers([pages.first!], direction: .forward, animated: false, completion: nil)
        currentVC = pages.first!
    }

}


// MARK: - UIPageViewControllerDataSource
extension OnBoardingPageController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getPreviousViewController(from: viewController)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getNextViewController(from: viewController)
    }

    private func getPreviousViewController(from viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index - 1 >= 0 else { return nil }
        currentVC = pages[index - 1]
        return pages[index - 1]
    }

    private func getNextViewController(from viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index + 1 < pages.count else { return nil }
        currentVC = pages[index + 1]
        return pages[index + 1]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pages.firstIndex(of: self.currentVC) ?? 0
    }
}
