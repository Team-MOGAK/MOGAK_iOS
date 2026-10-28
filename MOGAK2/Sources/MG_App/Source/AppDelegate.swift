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
        clearTokensIfReinstalled()
        MG2AppComposition.shared.adPolicyUseCase.registerLaunch()
        MG2AppComposition.shared.connectPieceIntents()

        return true
    }

    /// 펼친 폴더블(Duo)처럼 짧은 변이 600pt 이상인 화면에서만 가로를 허용한다.
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        guard let bounds = window?.windowScene?.screen.bounds, min(bounds.width, bounds.height) >= 600 else { return .portrait }
        return .allButUpsideDown
    }

    // 키체인은 앱을 지워도 남기 때문에, 재설치 후 첫 실행이면 이전 설치의 로그인 토큰을 지운다.
    private func clearTokensIfReinstalled() {
        let installMarkerKey = "MG2HasInstalledBefore"
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: installMarkerKey) else { return }

        defaults.set(true, forKey: installMarkerKey)
        MG2TokenStore.clearTokens()
    }
}
