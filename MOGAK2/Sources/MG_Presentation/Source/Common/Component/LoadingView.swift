//
//  LoadingView.swift
//  MOGAK
//
//  Created by 김라영 on 2024/03/20.
//

import UIKit

final class LoadingView: UIView {
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = DesignSystemColor.signature.value
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
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
        let loadingView: LoadingView
        if let existingView = view.subviews.first(where: { $0 is LoadingView }) as? LoadingView {
            loadingView = existingView
        } else {
            loadingView = LoadingView()
            view.addSubview(loadingView)
            loadingView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
        view.bringSubviewToFront(loadingView)
        loadingView.startAnimating()
    }

    func hideLoading() {
        view.subviews
            .filter { $0 is LoadingView }
            .forEach { $0.removeFromSuperview() }
    }
}
