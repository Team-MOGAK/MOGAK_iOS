//
//  SceneDelegate.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        lazy var firstVC: UIViewController = TabBarViewController()
//        lazy var firstVC: UIViewController = AppGuideViewController()

        //        let isFirst = UserDefaults.isFirstAppLauch()
        
        //        if isFirst {
        //            firstVC = UINavigationController(rootViewController: AppGuideViewController())
        //        } else if !UserDefaults.standard.isPermAgreed {
        //            firstVC = PermAgreeViewController()
        //        }
        
        //firstVC = UINavigationController(rootViewController: LoginViewController())
//        firstVC = UINavigationController(rootViewController: AppGuideViewController())
        
        window = UIWindow(windowScene: windowScene)
        
        window?.rootViewController = firstVC
        
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
        
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: "/*user의 고유 ID값(xxxxx.xxxxxxxxxx.xxxx)*/") { (credentialState, error) in
            switch credentialState {
            case .authorized:
                print("authorized")
                // The Apple ID credential is valid.
                DispatchQueue.main.async {
                    //authorized된 상태이므로 바로 로그인 완료 화면으로 이동
                    self.window?.rootViewController = TabBarViewController()
                }
            case .revoked:
                print("revoked")
            case .notFound:
                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                print("notFound")
                
            default:
                break
            }
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

