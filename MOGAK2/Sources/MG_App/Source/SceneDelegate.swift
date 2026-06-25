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
        guard let windowScene = scene as? UIWindowScene else { return }

        Task { [weak self, weak windowScene] in
            guard let self else { return }
            let route = await launchViewModel.resolveInitialRoute()
            await MainActor.run {
                guard let windowScene else { return }
                self.applyRoute(windowScene, route: route, markInitialResolved: true)
            }
        }

        MG2Deps.app.userState.$loginState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loginState in
                guard let self else { return }
                guard self.didResolveInitialRoute else { return }
                let route = self.launchViewModel.resolveRoute(loginState: loginState)
                self.applyRoute(windowScene, route: route)
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
//        if MG2KakaoLoginManage.handleOpenUrl(url) { return }
//        if MG2GoogleLoginManage.handleOpenUrl(url) { return }
    }

    private func applyRoute(_ windowScene: UIWindowScene, route: MG2AppLaunchRoute, markInitialResolved: Bool = false) {
        if markInitialResolved {
            didResolveInitialRoute = true
        }
        setRootViewController(windowScene, route: route)
        presentGlobalErrorIfNeeded()
    }

    private func setRootViewController(_ windowScene: UIWindowScene, route: MG2AppLaunchRoute) {
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

    private func presentGlobalErrorIfNeeded() {
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
