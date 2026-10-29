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
    private var currentRoute: MG2AppLaunchRoute?
    private var currentLoginState: MG2LoginStatus?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        applyRoute(windowScene, route: .launch)

        Publishers.CombineLatest(composition.userState.$loginState.removeDuplicates(), composition.userState.$isRegistered.removeDuplicates())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loginState, _ in
                // 첫 화면은 서버 확인이 끝난 뒤 finishLaunch가 정한다.
                guard let self, currentRoute != .launch else { return }
                let route = appFlowCoordinator.resolveRoute(loginState: loginState)
                // 게스트→로그인처럼 화면은 같아도 로그인 상태가 바뀌면 새 세션으로 다시 그린다.
                let requiresSessionRefresh = currentLoginState != loginState && currentRoute == route
                applyRoute(windowScene, route: route, force: requiresSessionRefresh)
            }
            .store(in: &cancellables)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 첫 실행 · 온보딩 · 로그인 중에는 권한을 묻지 않는다. 메인에 들어온 뒤에 묻는다.
        guard currentRoute == .main else { return }
        Task { await composition.requestStartupPermissions() }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        guard currentRoute == .main, composition.adPolicyUseCase.canShowAppOpenAd, let root = window?.rootViewController as? MG2MainTabViewController, root.allowsFullScreenAd else { return }
        composition.adProvider.presentAppOpen(from: root, isAllowed: { [weak root] in root?.allowsFullScreenAd == true }) { [composition] shown in
            if shown { composition.adPolicyUseCase.didShowAppOpenAd() }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        composition.adPolicyUseCase.didEnterBackground()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        MG2SocialLoginURLHandler.handle(url)
    }

    private func applyRoute(_ windowScene: UIWindowScene, route: MG2AppLaunchRoute, force: Bool = false) {
        guard force || currentRoute != route else { return }
        let previousRoute = currentRoute
        currentRoute = route
        currentLoginState = composition.userState.loginState

        let window = self.window ?? UIWindow(windowScene: windowScene)
        let root = appFlowCoordinator.makeRoot(for: route)
        if previousRoute == .launch {
            // 스플래시에서 첫 화면으로는 부드럽게 넘어간다.
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) { window.rootViewController = root }
        } else {
            window.rootViewController = root
        }
        self.window = window
        window.makeKeyAndVisible()
        if route == .main { Task { await composition.requestStartupPermissions() } }
    }
}
