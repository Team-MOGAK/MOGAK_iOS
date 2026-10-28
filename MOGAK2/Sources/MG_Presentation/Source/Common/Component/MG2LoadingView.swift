//
//  MG2LoadingView.swift
//  MOGAK
//
//  Created by 김라영 on 2024/03/20.
//

import UIKit

/// 화면을 덮는 `scrim` + 시스템 로딩 표시. 0.2초 페이드로 나타나고 사라진다.
final class MG2LoadingView: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DS.Color.scrim
        activityIndicator.color = DS.Color.accent
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        activityIndicator.startAnimating()
    }
}

extension UIViewController {
    func showLoading() {
        let loadingView = view.subviews.lazy.compactMap { $0 as? MG2LoadingView }.first ?? {
            let loadingView = MG2LoadingView()
            loadingView.alpha = 0
            view.addSubview(loadingView)
            loadingView.snp.makeConstraints { $0.edges.equalToSuperview() }
            return loadingView
        }()
        view.bringSubviewToFront(loadingView)
        loadingView.startAnimating()
        UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState) { loadingView.alpha = 1 }
    }

    /// 사라지는 중에 다시 showLoading이 불리면 그대로 남긴다.
    func hideLoading() {
        for loadingView in view.subviews.compactMap({ $0 as? MG2LoadingView }) {
            UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState) {
                loadingView.alpha = 0
            } completion: { _ in
                if loadingView.alpha == 0 { loadingView.removeFromSuperview() }
            }
        }
    }
}
