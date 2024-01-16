//
//  String+Ext.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/19.
//

import Foundation

extension String {
    func validateNickname() -> Bool {
        let regex = "^(?=.*[a-zA-Z가-힣])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-])[^\\s]+$"
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}
