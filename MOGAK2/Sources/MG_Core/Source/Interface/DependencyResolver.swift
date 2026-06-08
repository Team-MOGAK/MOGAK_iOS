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

extension DependencyResolver {
    func resolveRequired<T>(_ type: T.Type) -> T {
        guard let dependency = resolve(type) else {
            fatalError("\(String(describing: type)) is not registered. Call MG2DependencyBootstrap.registerDefault() first.")
        }
        return dependency
    }
}
