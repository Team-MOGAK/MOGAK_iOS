//
//  SceneDelegate.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit
import Combine

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private var cancellables = Set<AnyCancellable>()
    var window: UIWindow?

    private lazy var launchViewModel: MG2AppLaunchViewModel =
        DIContainer.shared.resolveRequired(MG2AppLaunchViewModel.self)
    private lazy var appDependencies: MG2AppDependencies =
        DIContainer.shared.resolveRequired(MG2AppDependencies.self)
    private lazy var appFlowCoordinator: MG2AppFlowCoordinator = {
        let coordinator = MG2CoordinatorFactory.makeAppFlowCoordinator(
            launchViewModel: launchViewModel
        )
        coordinator.onRouteChange = { [weak self] route in
            guard let self, let windowScene = window?.windowScene else { return }
            applyRoute(windowScene, route: route)
        }
        return coordinator
    }()
    private var didResolveInitialRoute = false
    private var currentRoute: MG2AppLaunchRoute?
    private var currentLoginState: MG2LoginStatus?

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

        Publishers.CombineLatest(
            appDependencies.userState.$loginState.removeDuplicates(),
            appDependencies.userState.$isRegistered.removeDuplicates()
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loginState, _ in
                guard let self else { return }
                guard self.didResolveInitialRoute else { return }
                let route = self.launchViewModel.resolveRoute(loginState: loginState)
                let requiresSessionRefresh = self.currentLoginState != loginState
                    && self.currentRoute == route
                self.applyRoute(
                    windowScene,
                    route: route,
                    force: requiresSessionRefresh
                )
            }
            .store(in: &cancellables)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        _ = MG2SocialLoginURLHandler.handle(url)
    }

    private func applyRoute(
        _ windowScene: UIWindowScene,
        route: MG2AppLaunchRoute,
        markInitialResolved: Bool = false,
        force: Bool = false
    ) {
        if markInitialResolved {
            didResolveInitialRoute = true
        }
        guard force || currentRoute != route else { return }
        currentRoute = route
        currentLoginState = appDependencies.userState.loginState
        setRootViewController(windowScene, route: route)
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

}
