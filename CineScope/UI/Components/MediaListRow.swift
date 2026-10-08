import SwiftUI
import CineScopeCore

struct MediaListRow: View {
    let media: Media
    let imagePipeline: ImagePipeline
    var isFavorite: Bool = false
    var showsFavoriteButton: Bool = true
    let onSelect: () -> Void
    var onFavorite: (() -> Void)?

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                RemotePosterView(
                    path: media.posterPath,
                    imagePipeline: imagePipeline,
                    maxSize: .w185,
                    loadsProgressively: false
                )
                .frame(width: 64, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(media.title)
                        .font(.headline)
                        .foregroundStyle(Color.cinePrimaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Text(media.mediaKind == .movie ? "Movie" : "Series")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(media.mediaKind == .movie ? Color.paletteBlue : Color.paletteTeal)

                        Text(String(format: "★ %.1f", media.voteAverage))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.paletteYellow)
                    }

                    Text(media.shortDescription)
                        .font(.subheadline)
                        .foregroundStyle(Color.cineSecondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                if showsFavoriteButton, let onFavorite {
                    Button(action: onFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(isFavorite ? Color.cineFavorite : Color.cineSecondaryText)
                            .padding(8)
                            .background(Color.cineBackground.opacity(0.55), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("media.favorite.button")
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.cineTertiaryText)
                }
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.cineCard)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.palettePrimary.opacity(0.35), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("media.list.row.\(media.id)")
    }
}
