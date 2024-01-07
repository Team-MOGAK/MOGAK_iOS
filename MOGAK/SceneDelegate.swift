//
//  SceneDelegate.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit
import Combine
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var cancellables = Set<AnyCancellable>()
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = scene as? UIWindowScene else { return }
        setRootViewController(scene)
        
//        lazy var firstVC: UIViewController = LoginViewController()
//        lazy var firstVC: UIViewController = TabBarViewController()
//        lazy var firstVC: UIViewController 0= AppGuideViewController()

        //        let isFirst = UserDefaults.isFirstAppLauch()
        
        //        if isFirst {
        //            firstVC = UINavigationController(rootViewController: AppGuideViewController())
        //        } else if !UserDefaults.standard.isPermAgreed {
        //            firstVC = PermAgreeViewController()
        //        }
        
        //firstVC = UINavigationController(rootViewController: LoginViewController())
        //firstVC = UINavigationController(rootViewController: AppGuideViewController())
//        window = UIWindow(windowScene: windowScene)
//
//        window?.rootViewController = firstVC
//
//        window?.makeKeyAndVisible()
//        window?.windowScene = windowScene
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        RegisterUserInfo.shared.$loginState.sink { loginState in
            if let loginState = loginState {
                if loginState {
                    if RegisterUserInfo.shared.userIsRegistered {
                        self.setRootViewContrller(scene, type: .main)
                    } else {
                        self.setRootViewContrller(scene, type: .termAgree)

                    }
                }else {
                    self.setRootViewContrller(scene, type: .login)
//                    print(#fileID, #function, #line, "- 로그인 완료
                }
            }
        }
        .store(in: &cancellables)

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

enum StartViewControllerType {
    case login
    case termAgree
    case main
    case onBoarding
    
    var vc: UIViewController {
        switch self {
        case .login: return LoginViewController()
        case .termAgree: return TermsAgreeViewController()
        case .main: return TabBarViewController()
//        case .login: return TabBarViewController()
        case .onBoarding: return AppGuideViewController()
        }
    }
}

extension SceneDelegate {
    private func setRootViewController(_ scene: UIScene) {
        let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
        print(#fileID, #function, #line, "- refreshToken: \(refreshToken)")
        if Storage.isFirstTime() {
            setRootViewContrller(scene, type: .onBoarding)
        }
        else if refreshToken != "" {
            setRootViewContrller(scene, type: .main)
        }
        else {
            setRootViewContrller(scene, type: .login)
        }
    }
    
    private func setRootViewContrller(_ scene: UIScene, type: StartViewControllerType) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            print(#fileID, #function, #line, "- 어떤 type의 data인지 확인하기⭐️: \(type)")
            window.rootViewController = type.vc //그에 맞게 Rootview를 변경해준다
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

public class Storage {
    static func isFirstTime() -> Bool {
        let defaults = UserDefaults.standard //defaults DB를 가지고 온다
        if defaults.object(forKey: "isFirstTime") == nil { //해당 DB에서 isFirstTime이라는 키가 있느지 체크한다
            defaults.set(true, forKey: "isFirstTime")
            return true
        } else {
            let isFirstTime = UserDefaults.standard.bool(forKey: "isFirstTime") //isFirstTime인지 체크하기
            return isFirstTime
        }
    }
}

