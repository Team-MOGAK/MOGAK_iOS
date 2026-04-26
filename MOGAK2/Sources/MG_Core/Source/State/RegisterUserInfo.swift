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
    
//    var loginState: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
//
//    var profileImage : CurrentValueSubject<String?, Never> = CurrentValueSubject("")
//    var nickName : CurrentValueSubject<String?, Never> = CurrentValueSubject("")
//    var userName : CurrentValueSubject<String?, Never> = CurrentValueSubject("")
//    var userEmail : CurrentValueSubject<String?, Never> = CurrentValueSubject("")
//    var userJob : CurrentValueSubject<String?, Never> = CurrentValueSubject("")
//    var userRegion : CurrentValueSubject<String?, Never> = CurrentValueSubject("")
//    var userId: CurrentValueSubject<String?, Never> = CurrentValueSubject("")
//    var userAccessToken: CurrentValueSubject<String?, Never> = CurrentValueSubject("")
    @Published var loginState: LoginStatus? = nil
    
    @Published var userIsRegistered: Bool = false
    @Published var someError: String? = nil
    @Published var happendSomeError: Bool = false

//    @Published var profileImage : UIImage? = UIImage(named: "setProfile")
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
