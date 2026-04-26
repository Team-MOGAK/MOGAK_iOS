import UIKit

enum MG2LegacyViewFactory {
    static func makeLoginViewController() -> UIViewController {
        MG2LoginCoordinator().start()
    }

    static func makeTermsAgreeViewController() -> UIViewController {
        MG2LoginCoordinator().makeTerms()
    }

    static func makeScheduleStartViewController() -> UIViewController {
        MG2ScheduleStartCoordinator().start()
    }

    static func makeModalartMainViewController() -> UIViewController {
        MG2ModalartCoordinator().start()
    }

    static func makeMyPageViewController() -> UIViewController {
        MG2MyPageCoordinator().start()
    }
}
