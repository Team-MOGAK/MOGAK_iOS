import Foundation

@MainActor
final class MG2OnboardingViewModel {
    private static let startEnabledFromPage = 2

    private let authUseCase: AuthUseCase

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    func canStart(onPage page: Int) -> Bool {
        page >= Self.startEnabledFromPage
    }

    func completeOnboarding() {
        authUseCase.completeOnboarding()
    }
}
