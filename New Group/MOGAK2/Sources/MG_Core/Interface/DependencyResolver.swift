//
//  DependencyResolver.swift
//  MOGAK
//
//  Created by 안세훈 on 3/22/26.
//


import Foundation

public protocol DependencyResolver {
    func resolve<T>(_ type: T.Type) -> T?
}