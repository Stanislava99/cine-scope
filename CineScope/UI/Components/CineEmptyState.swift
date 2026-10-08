import SwiftUI

struct CineEmptyState: View {
    let title: String
    let systemImage: String
    let message: String
    var accent: Color = .cinePrimary

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(accent)
                .padding(22)
                .background {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [accent.opacity(0.35), accent.opacity(0.12)],
                                center: .center,
                                startRadius: 4,
                                endRadius: 48
                            )
                        )
                }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.cinePrimaryText)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.cineSecondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
