@MainActor
protocol MG2SocialTokenProviding: AnyObject {
    func token() async throws -> String
}
