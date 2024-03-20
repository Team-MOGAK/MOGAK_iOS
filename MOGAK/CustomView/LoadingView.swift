//
//  LoadingView.swift
//  MOGAK
//
//  Created by 김라영 on 2024/03/20.
//

import Foundation
import Lottie

final class LoadingView: UIView {
    static let shared = LoadingView()
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0
        return view
    }()
    
    private let loadingView: LottieAnimationView = {
        let view = LottieAnimationView(name: "loading")
        view.loopMode = .loop
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black.withAlphaComponent(0.3)
        
        self.addSubviews(self.contentView)
        self.contentView.addSubview(self.loadingView)
        
        self.contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(500)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
//        guard !AppDelegate.window.subviews.contains(where: { $0 is LoadingView }) else { return }
//        
//        AppDelegate.window.addSubview(self)
//        
//        self.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//        
//        self.layoutIfNeeded()
////
        
        self.loadingView.isHidden = false
        self.loadingView.play()
        
//        UIView.animate(
//            withDuration: 0.7,
//            animations: { self.contentView.alpha = 1 }
//        )
    }
    
    
    func hide(completion: @escaping () -> () = {}) {
//        self.loadingView.isHidden = false
        self.loadingView.stop()
        self.removeFromSuperview()
        completion()
    }
}
