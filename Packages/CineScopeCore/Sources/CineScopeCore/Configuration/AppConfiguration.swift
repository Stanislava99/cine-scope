import Foundation

public struct AppConfiguration: Sendable, Equatable {
    public let environment: AppEnvironment
    public let apiBaseURL: URL
    public let imageBaseURL: URL
    public let accessToken: String?
    public let prefersFixtureClient: Bool

    public init(
        environment: AppEnvironment,
        apiBaseURL: URL = URL(string: "https://api.themoviedb.org")!,
        imageBaseURL: URL = URL(string: "https://image.tmdb.org/t/p")!,
        accessToken: String?,
        prefersFixtureClient: Bool
    ) {
        self.environment = environment
        self.apiBaseURL = apiBaseURL
        self.imageBaseURL = imageBaseURL
        self.accessToken = accessToken
        self.prefersFixtureClient = prefersFixtureClient
    }

    public var usesLiveAPI: Bool {
        !prefersFixtureClient && !(accessToken?.isEmpty ?? true)
    }

    public var clientModeDescription: String {
        usesLiveAPI ? "Live API" : "Fixture"
    }

    public static func resolve(
        environmentName: String?,
        accessToken: String?,
        processInfo: ProcessInfo = .processInfo
    ) -> AppConfiguration {
        let envRaw = environmentName
            ?? processInfo.environment["APP_ENVIRONMENT"]
            ?? "Dev"
        let environment = AppEnvironment(rawValue: envRaw) ?? .development

        let tokenFromEnv = processInfo.environment["TMDB_ACCESS_TOKEN"]
        let resolvedToken = firstNonEmpty(tokenFromEnv, accessToken)

        let prefersFixture: Bool
        switch environment {
        case .development:
            prefersFixture = resolvedToken == nil
        case .production:
            prefersFixture = false
        }

        return AppConfiguration(
            environment: environment,
            accessToken: resolvedToken,
            prefersFixtureClient: prefersFixture
        )
    }

    private static func firstNonEmpty(_ values: String?...) -> String? {
        for value in values {
            if let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }
}
