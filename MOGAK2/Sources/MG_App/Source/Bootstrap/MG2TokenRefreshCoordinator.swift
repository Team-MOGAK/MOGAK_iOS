import Foundation

actor MG2TokenRefreshCoordinator {
    typealias RefreshOperation = (String) async throws -> MG2TokenPair

    private let sessionStore: MG2SessionStoring
    private let refreshOperation: RefreshOperation
    private var refreshTask: Task<String, Error>?

    init(
        sessionStore: MG2SessionStoring,
        refreshOperation: @escaping RefreshOperation
    ) {
        self.sessionStore = sessionStore
        self.refreshOperation = refreshOperation
    }

    func refreshAccessToken() async throws -> String? {
        if let refreshTask {
            return try await refreshTask.value
        }

        guard let refreshToken = sessionStore.refreshToken, !refreshToken.isEmpty else {
            return nil
        }

        let task = Task { [sessionStore, refreshOperation] in
            let tokens = try await refreshOperation(refreshToken)
            sessionStore.saveTokens(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken
            )
            return tokens.accessToken
        }
        refreshTask = task
        defer { refreshTask = nil }
        return try await task.value
    }
}
