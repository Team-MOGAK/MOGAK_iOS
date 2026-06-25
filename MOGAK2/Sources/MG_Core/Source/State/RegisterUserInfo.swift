//
//  RegisterUserInfo.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/19.
//

import Foundation
import Combine
import UIKit

class RegisterUserInfo {
    static let shared = RegisterUserInfo()

    @Published var loginState: LoginStatus? = nil

    @Published var userIsRegistered: Bool = false
    @Published var someError: String? = nil
    @Published var happendSomeError: Bool = false

    @Published var profileImage : UIImage? = nil
    @Published var nickName : String? = ""
    @Published var userName : String? = ""
    @Published var userEmail : String? = ""
    @Published var userJob : String? = ""
    @Published var userRegion : String? = ""
    @Published var userId: String? = ""
    @Published var userAccessToken: String? = ""
    
    private init() {}
}
