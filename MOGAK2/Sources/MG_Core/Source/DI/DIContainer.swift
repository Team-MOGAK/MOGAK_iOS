import Foundation

typealias DependencyInjectable = DependencyResolver & DependencyAssembler

public final class DIContainer: DependencyInjectable {
    public static let shared = DIContainer()

    private var services: [ObjectIdentifier: DependencyContainerClosure] = [:]

    public func register<T>(_ type: T.Type, factory: @escaping (DependencyResolver) -> T) {
        services[ObjectIdentifier(type)] = factory
    }

    public func registerMainActor<T>(
        _ type: T.Type,
        factory: @escaping @MainActor (DependencyResolver) -> T
    ) {
        services[ObjectIdentifier(type)] = { resolver in
            MainActor.assumeIsolated {
                factory(resolver)
            }
        }
    }

    public func resolve<T>(_ type: T.Type) -> T? {
        services[ObjectIdentifier(type)]?(self) as? T
    }
}
