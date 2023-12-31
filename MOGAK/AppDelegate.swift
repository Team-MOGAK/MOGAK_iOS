//
//  AppDelegate.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit
import AuthenticationServices

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        appleIDProvider.getCredentialState(forUserID: "/*user의 고유 ID값(xxxxx.xxxxxxxxxx.xxxx)*/") { (credentialState, error) in
//            switch credentialState {
//            case .authorized:
//                print("authorized")
//                // The Apple ID credential is valid.
//                DispatchQueue.main.async {
//                    //authorized된 상태이므로 바로 로그인 완료 화면으로 이동
//                    self.window?.rootViewController = TabBarViewController()
//                }
//            case .revoked:
//                print("revoked")
//            case .notFound:
//                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
//                print("notFound")
//                
//            default:
//                break
//            }
//        }
//        sleep(3)
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

