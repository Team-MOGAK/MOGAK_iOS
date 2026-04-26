//
//  DependencyAssembler.swift
//  MOGAK
//
//  Created by 안세훈 on 3/22/26.
//


import Foundation

public typealias DependencyContainerClosure = (DependencyResolver) -> Any

public protocol DependencyAssembler {
    func register<T>(_ type: T.Type, factory: @escaping (DependencyResolver) -> T)
}