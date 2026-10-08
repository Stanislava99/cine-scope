import SwiftUI
import CineScopeCore

struct RootView: View {
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        TrendingView()
            .tint(Color.cinePrimary)
            .preferredColorScheme(.dark)
            .cineScreenBackground()
            .overlay(alignment: .bottomLeading) {
                EnvironmentBadge(
                    environment: dependencies.configuration.environment,
                    clientMode: dependencies.configuration.clientModeDescription
                )
                .padding(.leading, 16)
                .padding(.bottom, 16)
            }
    }
}

private struct EnvironmentBadge: View {
    let environment: AppEnvironment
    let clientMode: String

    var body: some View {
        Text("\(environment.displayName) · \(clientMode)")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill(CineGradient.primaryBlue.opacity(0.85))
            }
            .accessibilityIdentifier("environment.badge")
    }
}
