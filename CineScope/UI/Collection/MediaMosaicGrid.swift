import SwiftUI
import CineScopeCore

struct MediaMosaicGrid: View {
    let items: [Media]
    let favoriteKeys: Set<String>
    let imagePipeline: ImagePipeline
    let isLoadingMore: Bool
    let onSelect: (Media) -> Void
    let onFavorite: (Media) -> Void
    let onNearEnd: (Media) -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        GeometryReader { proxy in
            let columns = columnCount(for: proxy.size.width)
            let gridColumns = Array(
                repeating: GridItem(.flexible(), spacing: 12),
                count: columns
            )

            ScrollView {
                LazyVStack(spacing: 12) {
                    if let featured = items.first {
                        card(for: featured, isFeatured: true)
                            .frame(maxWidth: .infinity)
                            .frame(height: max(220, proxy.size.width * 0.55))
                    }

                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        ForEach(items.dropFirst()) { media in
                            card(for: media, isFeatured: false)
                                .aspectRatio(1 / 1.45, contentMode: .fit)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                if isLoadingMore {
                    ProgressView()
                        .tint(.cineAccent)
                        .padding(.bottom, 24)
                }
            }
            .accessibilityIdentifier("media.collection")
        }
    }

    @ViewBuilder
    private func card(for media: Media, isFeatured: Bool) -> some View {
        Button {
            onSelect(media)
        } label: {
            MediaCardView(
                media: media,
                isFavorite: favoriteKeys.contains(FavoritesStore.key(for: media)),
                isFeatured: isFeatured,
                imagePipeline: imagePipeline,
                onFavorite: { onFavorite(media) }
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("media.card.\(media.id)")
        .accessibilityLabel(media.title)
        .onAppear {
            onNearEnd(media)
        }
    }

    private func columnCount(for width: CGFloat) -> Int {
        if sizeClass == .regular {
            if width > 1100 { return 4 }
            if width > 800 { return 3 }
            return 3
        }
        return width > 700 ? 3 : 2
    }
}
