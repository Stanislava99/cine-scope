import SwiftUI
import CineScopeCore

struct MediaCardView: View {
    let media: Media
    let isFavorite: Bool
    let isFeatured: Bool
    let imagePipeline: ImagePipeline
    let onFavorite: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RemotePosterView(
                path: media.posterPath,
                imagePipeline: imagePipeline,
                cornerRadius: 0,
                maxSize: .w342,
                loadsProgressively: false
            )

            LinearGradient(
                colors: [
                    .clear,
                    Color.palettePrimary.opacity(0.25),
                    Color.paletteBackground.opacity(0.88)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(media.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(media.shortDescription)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(isFeatured ? 3 : 2)
            }
            .padding(12)
        }
        .background(Color.cineCard)
        .clipShape(RoundedRectangle(cornerRadius: CineTheme.cardCornerRadius, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Button(action: onFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isFavorite ? Color.cineFavorite : .white)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .padding(8)
            .accessibilityIdentifier("media.favorite.button")
        }
    }
}
