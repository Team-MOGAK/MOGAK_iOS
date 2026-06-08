//
//  SceneDelegate.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var cancellables = Set<AnyCancellable>()
    var window: UIWindow?

    private let appFlowCoordinator = MG2AppFlowCoordinator()
    private let launchViewModel: MG2AppLaunchViewModel = DIContainer.shared.resolveRequired(MG2AppLaunchViewModel.self)
    private var didResolveInitialRoute = false

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard scene is UIWindowScene else { return }

        Task {
            let route = await launchViewModel.resolveInitialRoute()
            applyRoute(scene, route: route, markInitialResolved: true)
        }

        MG2Deps.app.userState.$loginState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loginState in
                guard let self else { return }
                guard self.didResolveInitialRoute else { return }
                let route = self.launchViewModel.resolveRoute(loginState: loginState)
                Task {
                    self.applyRoute(scene, route: route)
                }
            }
            .store(in: &cancellables)
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}

    @MainActor
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        if MG2KakaoLoginManage.handleOpenUrl(url) { return }
        if MG2GoogleLoginManage.handleOpenUrl(url) { return }
    }
}

private extension SceneDelegate {
    @MainActor
    func applyRoute(_ scene: UIScene, route: MG2AppLaunchRoute, markInitialResolved: Bool = false) {
        if markInitialResolved {
            didResolveInitialRoute = true
        }
        setRootViewController(scene, route: route)
        presentGlobalErrorIfNeeded()
    }

    @MainActor
    func setRootViewController(_ scene: UIScene, route: MG2AppLaunchRoute) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let rootViewController = self.appFlowCoordinator.makeRoot(for: route)

        if let window = self.window {
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
        } else {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = rootViewController
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    @MainActor
    func presentGlobalErrorIfNeeded() {
        guard MG2Deps.app.userState.happendSomeError,
              let message = MG2Deps.app.userState.someError else { return }

        let alertController = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            MG2Deps.app.userState.happendSomeError = false
            MG2Deps.app.userState.someError = nil
        }
        alertController.addAction(okAction)

        window?.rootViewController?.present(alertController, animated: false)
    }
}

public class Storage {
    static func isFirstTime() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isFirstTime") == nil {
            defaults.set(true, forKey: "isFirstTime")
            return true
        } else {
            let isFirstTime = UserDefaults.standard.bool(forKey: "isFirstTime")
            return isFirstTime
        }
    }

    static func setFirstTime(_ isFirstTime: Bool) {
        UserDefaults.standard.set(isFirstTime, forKey: "isFirstTime")
    }
}
