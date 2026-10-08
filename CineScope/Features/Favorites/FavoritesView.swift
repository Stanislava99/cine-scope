import SwiftUI
import CineScopeCore

struct FavoritesView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(FavoritesController.self) private var favorites
    @State private var viewModel: FavoritesViewModel?

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                ProgressView()
                    .tint(.cinePrimary)
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .cineScreenBackground()
        .task {
            if viewModel == nil {
                viewModel = FavoritesViewModel(favorites: favorites)
            }
        }
    }

    @ViewBuilder
    private func content(_ viewModel: FavoritesViewModel) -> some View {
        @Bindable var viewModel = viewModel
        let items = favorites.items

        Group {
            if items.isEmpty {
                CineEmptyState(
                    title: "No favorites yet",
                    systemImage: "heart.fill",
                    message: "Tap the heart on any movie or series to keep it here for offline access.",
                    accent: .cineFavorite
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        Text("\(items.count) saved locally")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.cineTertiaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)

                        ForEach(items) { media in
                            FavoriteRow(
                                media: media,
                                imagePipeline: dependencies.imagePipeline
                            ) {
                                viewModel.select(media)
                            } onRemove: {
                                withAnimation(.easeInOut) {
                                    viewModel.remove(media)
                                }
                            }
                            .accessibilityIdentifier("favorites.row.\(media.id)")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationDestination(item: $viewModel.selectedMedia) { media in
            DetailsView(media: media)
        }
    }
}

private struct FavoriteRow: View {
    let media: Media
    let imagePipeline: ImagePipeline
    let onSelect: () -> Void
    let onRemove: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                RemotePosterView(
                    path: media.posterPath,
                    imagePipeline: imagePipeline,
                    maxSize: .w185,
                    loadsProgressively: false
                )
                .frame(width: 72, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(media.title)
                            .font(.headline)
                            .foregroundStyle(Color.cinePrimaryText)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)

                        Spacer(minLength: 0)

                        Text(String(format: "%.1f", media.voteAverage))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.cinePrimaryText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.paletteYellow.opacity(0.22), in: Capsule())
                            .overlay {
                                Capsule().stroke(Color.paletteYellow.opacity(0.55), lineWidth: 1)
                            }
                    }

                    Text(media.mediaKind == .movie ? "Movie" : "Series")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(media.mediaKind == .movie ? Color.paletteBlue : Color.paletteTeal)

                    Text(media.shortDescription)
                        .font(.subheadline)
                        .foregroundStyle(Color.cineSecondaryText)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.cineTertiaryText)
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.cineCard)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.palettePrimary.opacity(0.35), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive, action: onRemove) {
                Label("Remove from Favorites", systemImage: "heart.slash")
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onRemove) {
                Image(systemName: "heart.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.cineFavorite)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .padding(10)
            .accessibilityLabel("Remove from favorites")
        }
    }
}
