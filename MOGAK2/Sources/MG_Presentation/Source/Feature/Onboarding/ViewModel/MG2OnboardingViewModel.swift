import Foundation

final class MG2OnboardingViewModel {
    let pageCount: Int = 4
    let startEnabledFromPage: Int = 2

    var lastPageIndex: Int { pageCount - 1 }
}
