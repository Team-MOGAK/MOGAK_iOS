import Foundation

@MainActor
enum MG2CoordinatorFactory {
    static func makeAppFlowCoordinator(
        launchViewModel: MG2AppLaunchViewModel,
        container: DIContainer = .shared
    ) -> MG2AppFlowCoordinator {
        let loginCoordinator = MG2LoginCoordinator(
            loginViewModel: container.resolveRequired(MG2LoginViewModel.self),
            profileViewModel: container.resolveRequired(MG2ProfileSetupViewModel.self)
        )
        let formCoordinator = MG2MogakJogakFormCoordinator(
            makeMogakViewModel: {
                container.resolveRequired(MG2MogakFormViewModel.self)
            },
            makeJogakViewModel: {
                container.resolveRequired(MG2JogakFormViewModel.self)
            }
        )
        let scheduleStartCoordinator = MG2ScheduleStartCoordinator(
            viewModel: container.resolveRequired(MG2ScheduleStartViewModel.self),
            makeJogakSelectionViewModel: {
                container.resolveRequired(MG2JogakSelectionViewModel.self)
            },
            formCoordinator: formCoordinator,
            loginCoordinator: loginCoordinator
        )
        let modalartCoordinator = MG2ModalartCoordinator(
            viewModel: container.resolveRequired(MG2ModalartViewModel.self),
            makeMogakDetailViewModel: { modalartID, mogaks, selectedMogak, occurrences in
                MG2MogakDetailViewModel(
                    useCase: container.resolveRequired(ModalartUseCase.self),
                    scheduleUseCase: container.resolveRequired(ScheduleStartUseCase.self),
                    modalartID: modalartID,
                    mogaks: mogaks,
                    selectedMogak: selectedMogak,
                    occurrences: occurrences
                )
            },
            formCoordinator: formCoordinator,
            loginCoordinator: loginCoordinator
        )
        let myPageCoordinator = MG2MyPageCoordinator(
            viewModel: container.resolveRequired(MG2MyPageViewModel.self),
            loginCoordinator: loginCoordinator
        )
        let tabBarCoordinator = MG2TabBarCoordinator(
            viewModel: container.resolveRequired(MG2MainTabBarViewModel.self),
            scheduleStartCoordinator: scheduleStartCoordinator,
            modalartCoordinator: modalartCoordinator,
            myPageCoordinator: myPageCoordinator
        )
        let onboardingCoordinator = MG2OnboardingCoordinator(
            viewModel: container.resolveRequired(MG2OnboardingViewModel.self)
        )

        return MG2AppFlowCoordinator(
            viewModel: launchViewModel,
            loginCoordinator: loginCoordinator,
            tabBarCoordinator: tabBarCoordinator,
            onboardingCoordinator: onboardingCoordinator
        )
    }
}
