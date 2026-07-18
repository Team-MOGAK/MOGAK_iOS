//
//  AppDelegate.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private let appDependencies = MG2DefaultAppDependencies()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MG2DependencyBootstrap.registerDefault(
            container: .shared,
            appDependencies: appDependencies
        )
        MG2GoogleLoginManager.configureSDK()
        MG2KakaoLoginManager.configureSDK()
        prepareAuthStorage()

        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @MainActor
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        MG2SocialLoginURLHandler.handle(url)
    }

    private func prepareAuthStorage() {
        let installMarkerKey = "MG2HasInstalledBefore"
        let defaults = UserDefaults.standard

        guard defaults.bool(forKey: installMarkerKey) == false else { return }

        defaults.set(true, forKey: installMarkerKey)

        if hasLegacyToken(in: defaults) {
            return
        }

        MG2TokenStore.clearTokens()
        defaults.set(true, forKey: "isFirstTime")
    }

    private func hasLegacyToken(in defaults: UserDefaults) -> Bool {
        let accessToken = defaults.string(forKey: "accessToken") ?? ""
        let refreshToken = defaults.string(forKey: "refreshToken") ?? ""
        return !accessToken.isEmpty || !refreshToken.isEmpty
    }
}
