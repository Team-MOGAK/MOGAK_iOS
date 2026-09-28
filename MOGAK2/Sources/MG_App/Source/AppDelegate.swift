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

        return true
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
