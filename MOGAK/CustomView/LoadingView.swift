//
//  LoadingView.swift
//  MOGAK
//
//  Created by 김라영 on 2024/03/20.
//

import Foundation
import Lottie

final class LoadingView: UIView {
    let loadingView: LottieAnimationView = {
        let view = LottieAnimationView(name: "mogakLoading")
//        let view = LottieAnimationView(name: "loading")
        view.loopMode = .loop
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubviews(self.loadingView)
        
        self.loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(300)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class LoadingIndicator {
    static func showLoading() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }

            let loadingIndicatorView: LoadingView
            if let existedView = window.subviews.first(where: { $0 is LoadingView }) as? LoadingView {
                loadingIndicatorView = existedView
            } else {
                loadingIndicatorView = LoadingView()
                loadingIndicatorView.frame = window.frame
                loadingIndicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                window.addSubview(loadingIndicatorView)
            }
            
            loadingIndicatorView.loadingView.play()
        }
    }

    static func hideLoading() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
            window.subviews.filter({ $0 is LoadingView }).forEach {
                $0.removeFromSuperview()
            }
        }
    }
}
