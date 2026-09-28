import Foundation

/// 여러 요청이 동시에 토큰 갱신을 요구해도 갱신은 한 번만 한다.
actor MG2TokenRefreshCoordinator {
    private let refresh: @MainActor () async throws -> String?
    private var refreshTask: Task<String?, Error>?

    init(refresh: @escaping @MainActor () async throws -> String?) {
        self.refresh = refresh
    }

    func refreshAccessToken() async throws -> String? {
        if let refreshTask {
            return try await refreshTask.value
        }

        let task = Task { [refresh] in try await refresh() }
        refreshTask = task
        defer { refreshTask = nil }
        return try await task.value
    }
}
