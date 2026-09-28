//
//  SceneDelegate.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit
import Combine

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var cancellables = Set<AnyCancellable>()
    private let composition = MG2AppComposition.shared
    private lazy var appFlowCoordinator: MG2AppFlowCoordinator = {
        let coordinator = composition.makeAppFlowCoordinator()
        coordinator.onRouteChange = { [weak self] route in
            guard let self, let windowScene = window?.windowScene else { return }
            applyRoute(windowScene, route: route)
        }
        return coordinator
    }()
    private var didResolveInitialRoute = false
    private var currentRoute: MG2AppLaunchRoute?
    private var currentLoginState: MG2LoginStatus?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        Task { [weak self, weak windowScene] in
            guard let self else { return }
            let route = await appFlowCoordinator.resolveInitialRoute()
            guard let windowScene else { return }
            didResolveInitialRoute = true
            applyRoute(windowScene, route: route)
        }

        Publishers.CombineLatest(composition.userState.$loginState.removeDuplicates(), composition.userState.$isRegistered.removeDuplicates())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loginState, _ in
                guard let self, didResolveInitialRoute else { return }
                let route = appFlowCoordinator.resolveRoute(loginState: loginState)
                // 게스트→로그인처럼 화면은 같아도 로그인 상태가 바뀌면 새 세션으로 다시 그린다.
                let requiresSessionRefresh = currentLoginState != loginState && currentRoute == route
                applyRoute(windowScene, route: route, force: requiresSessionRefresh)
            }
            .store(in: &cancellables)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        MG2SocialLoginURLHandler.handle(url)
    }

    private func applyRoute(_ windowScene: UIWindowScene, route: MG2AppLaunchRoute, force: Bool = false) {
        guard force || currentRoute != route else { return }
        currentRoute = route
        currentLoginState = composition.userState.loginState

        let window = self.window ?? UIWindow(windowScene: windowScene)
        window.rootViewController = appFlowCoordinator.makeRoot(for: route)
        self.window = window
        window.makeKeyAndVisible()
    }
}
