//
//  AppDelegate.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MG2GoogleLoginManager.configureSDK()
        MG2KakaoLoginManager.configureSDK()
        MG2AppComposition.shared.adPolicyUseCase.registerLaunch()
        MG2AppComposition.shared.connectPieceIntents()

        return true
    }

    /// 펼친 폴더블(Duo)처럼 짧은 변이 600pt 이상인 화면에서만 가로를 허용한다.
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        guard let bounds = window?.windowScene?.screen.bounds, min(bounds.width, bounds.height) >= 600 else { return .portrait }
        return .allButUpsideDown
    }
}
