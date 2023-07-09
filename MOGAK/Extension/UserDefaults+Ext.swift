//
//  UserDefaults+Ext.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/08.
//

import Foundation

let NICKNAME_KEY = "nickname_key"
let PUSH_TIME_KEY = "push_time_key"

extension UserDefaults {
    
    enum Const {
        static let NICKNAME_KEY = "nickname_key"
        static let PUSH_TIME_KEY = "push_time_key"
        
        static let kIsPermAgreed = "isPermAgreed"
        static let kIsUserScore = "IsUserScore"
        
        static let kIsPushHour = "isPushHour"
        static let kIsPushMinute = "isPushMinute"
    }
    
    static func isFirstAppLauch() -> Bool {
        
        let firstLaunchFlag = "firstLaunchFlag"
        
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: firstLaunchFlag)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: firstLaunchFlag)
            UserDefaults.standard.synchronize()
        }
        
        return isFirstLaunch
    }
    
    var isPermAgreed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Const.kIsPermAgreed)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Const.kIsPermAgreed)
            UserDefaults.standard.synchronize()
        }
    }
    
    var pushHour: Int {
        get {
            return UserDefaults.standard.integer(forKey: Const.kIsPushHour)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Const.kIsPushHour)
            UserDefaults.standard.synchronize()
        }
    }
    
    var pushMinute: Int {
        get {
            return UserDefaults.standard.integer(forKey: Const.kIsPushMinute)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Const.kIsPushMinute)
            UserDefaults.standard.synchronize()
        }
    }
}
