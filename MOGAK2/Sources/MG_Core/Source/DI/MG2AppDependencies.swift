import Foundation
import UIKit

protocol MG2AppDependencies {
    var userState: RegisterUserInfo { get }

    // Data API Networks
    var scheduleStartNetwork: ApiNetwork { get }
    var modalartNetwork: ModalartNetwork { get }
    var mogakDetailNetwork: MogakDetailNetwork { get }
    var historyNetwork: HistoryNetwork { get }
    var userNetwork: MG2UserNetwork { get }
    var appleLoginManager: MG2AppleLoginManage { get }
    var networkingNetwork: MG2NetworkingNetwork { get }
}

final class MG2DefaultAppDependencies: MG2AppDependencies {
    let userState: RegisterUserInfo

    let scheduleStartNetwork: ApiNetwork
    let modalartNetwork: ModalartNetwork
    let mogakDetailNetwork: MogakDetailNetwork
    let historyNetwork: HistoryNetwork
    let userNetwork: MG2UserNetwork
    let appleLoginManager: MG2AppleLoginManage
    let networkingNetwork: MG2NetworkingNetwork

    init(
        userState: RegisterUserInfo = RegisterUserInfo.shared,
        scheduleStartNetwork: ApiNetwork = .shared,
        modalartNetwork: ModalartNetwork = .shared,
        mogakDetailNetwork: MogakDetailNetwork = .shared,
        historyNetwork: HistoryNetwork = .shared,
        userNetwork: MG2UserNetwork = .shared,
        appleLoginManager: MG2AppleLoginManage = .shared,
        networkingNetwork: MG2NetworkingNetwork = .shared
    ) {
        self.userState = userState
        self.scheduleStartNetwork = scheduleStartNetwork
        self.modalartNetwork = modalartNetwork
        self.mogakDetailNetwork = mogakDetailNetwork
        self.historyNetwork = historyNetwork
        self.userNetwork = userNetwork
        self.appleLoginManager = appleLoginManager
        self.networkingNetwork = networkingNetwork
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
