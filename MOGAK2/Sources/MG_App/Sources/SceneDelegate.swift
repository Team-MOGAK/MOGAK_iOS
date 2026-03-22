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
        RegisterUserInfo.shared.$loginState.sink { loginState in
            let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")

            print(#fileID, #function, #line, "- sceneDelegate refreshToken: \(refreshToken)")
            if let loginState = loginState {
                //로그인이 되어있다면
                if loginState == .login {
                    if RegisterUserInfo.shared.userIsRegistered {
                        //이미 등록한 유저
                        self.setRootViewContrller(scene, type: .main)
                    } else {
                        //아직 등록하지 않은 유저
                        self.setRootViewContrller(scene, type: .termAgree)
                    }
                }
                // 게스트 로그인
                else if loginState == .guest {
                    self.setRootViewContrller(scene, type: .main)
                }
                // 로그아웃
                else {
                    //처음 등록한 유저라면
                    if Storage.isFirstTime() {
                        self.setRootViewContrller(scene, type: .onBoarding)
                    }
                    // 처음 등록한 유저가 아니고 refreshToken이 있다면
                    else if refreshToken != "" {
                        self.setRootViewContrller(scene, type: .main)
                    }
                    // refreshToken이 없다면
                    else {
                        self.setRootViewContrller(scene, type: .login)
                    }
//                    self.setRootViewContrller(scene, type: .main)
                }
            } else {
                if Storage.isFirstTime() {
                    self.setRootViewContrller(scene, type: .onBoarding)
                }
                else if refreshToken != "" {
                    self.setRootViewContrller(scene, type: .main)
                }
                else {
                    if RegisterUserInfo.shared.happendSomeError {
                        let alertController = UIAlertController(title: "에러", message: RegisterUserInfo.shared.someError, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                            RegisterUserInfo.shared.happendSomeError = false
                            RegisterUserInfo.shared.someError = nil
                        }
                        alertController.addAction(okAction)
                        self.window?.rootViewController?.present(alertController, animated: false)
                    }
                    
                    self.setRootViewContrller(scene, type: .login)
                }
                
//                self.setRootViewContrller(scene, type: .main)
            }
        }
        .store(in: &cancellables)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        

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
    case login //로그인
    case termAgree //이용동의
    case main //메인
    case onBoarding //온보딩화면
    
    var vc: UIViewController {
        switch self {
        case .login: return LoginViewController()
        case .termAgree: return TermsAgreeViewController()
        case .main: return TabBarViewController()
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
            DispatchQueue.main.async {
                let window = UIWindow(windowScene: windowScene)
                print(#fileID, #function, #line, "- 어떤 type의 data인지 확인하기⭐️: \(type)")
                if type == .termAgree {
                    let navigationController = UINavigationController(rootViewController: type.vc)
                    window.rootViewController = navigationController
                } else {
                    window.rootViewController = type.vc //그에 맞게 Rootview를 변경해준다
                }
                
                self.window = window
                window.makeKeyAndVisible()
            }
            
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

