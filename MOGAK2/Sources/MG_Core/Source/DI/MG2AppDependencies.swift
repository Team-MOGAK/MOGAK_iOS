import Foundation
import UIKit

protocol MG2AppDependencies {
    var userState: RegisterUserInfo { get }
}

final class MG2DefaultAppDependencies: MG2AppDependencies {
    let userState: RegisterUserInfo

    init(
        userState: RegisterUserInfo = RegisterUserInfo.shared
    ) {
        self.userState = userState
    }
}

enum MG2AppDI {
    static var shared: MG2AppDependencies = MG2DefaultAppDependencies()

    static func configure(_ dependencies: MG2AppDependencies) {
        shared = dependencies
    }
}

enum MG2Deps {
    static var app: MG2AppDependencies { MG2AppDI.shared }
}
