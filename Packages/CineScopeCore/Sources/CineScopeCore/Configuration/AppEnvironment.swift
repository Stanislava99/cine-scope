import Foundation

public enum AppEnvironment: String, Sendable, CaseIterable {
    case development = "Dev"
    case production = "Prod"

    public var displayName: String { rawValue }

    public var enablesVerboseLogging: Bool {
        self == .development
    }
}
