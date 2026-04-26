//
//  DIContainer.swift
//  MOGAK
//
//  Created by 안세훈 on 3/22/26.
//


import Foundation

typealias DependencyInjectable = DependencyResolver & DependencyAssembler

public final class DIContainer: DependencyInjectable {
    
    public static let shared = DIContainer()
    
    private var services: [String: DependencyContainerClosure] = [:]
    private var instances: [String: Any] = [:]
    
    public func register<T>(_ type: T.Type, factory: @escaping (DependencyResolver) -> T) {
        let key = String(describing: type)
        services[key] = factory
    }
    
    public func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        guard let service = services[key]?(self) as? T else { return nil }
        return service
    }
}