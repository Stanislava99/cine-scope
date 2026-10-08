import SwiftUI
import CineScopeCore

struct SearchResultsView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(FavoritesController.self) private var favorites
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                MediaKindPicker(selection: $viewModel.selectedKind)

                if !viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    HStack {
                        Text(statusText)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.cineTertiaryText)
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.cinePrimary)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 10)

            resultsArea
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var resultsArea: some View {
        let trimmed = viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines)

        if viewModel.isLoading && viewModel.items.isEmpty {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(.cinePrimary)
                Text("Searching…")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.cineSecondaryText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if trimmed.isEmpty {
            CineEmptyState(
                title: "Search movies & series",
                systemImage: "magnifyingglass",
                message: "Choose Movies or Series, then type a title. Results update as you type."
            )
        } else if let errorMessage = viewModel.errorMessage, viewModel.items.isEmpty {
            CineEmptyState(
                title: "Something went wrong",
                systemImage: "exclamationmark.triangle.fill",
                message: errorMessage,
                accent: .paletteOrange
            )
        } else if viewModel.items.isEmpty {
            CineEmptyState(
                title: "No matches",
                systemImage: "film.stack",
                message: "Nothing matched “\(trimmed)”. Try another title.",
                accent: .paletteTeal
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.items) { media in
                        MediaListRow(
                            media: media,
                            imagePipeline: dependencies.imagePipeline,
                            isFavorite: favorites.isFavorite(media),
                            onSelect: { viewModel.select(media) },
                            onFavorite: {
                                Task { await favorites.toggle(media) }
                            }
                        )
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentItem: media)
                        }
                    }

                    if viewModel.isLoadingMore {
                        ProgressView()
                            .tint(.cinePrimary)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .accessibilityIdentifier("media.search.list")
        }
    }

    private var statusText: String {
        if viewModel.isLoading && viewModel.items.isEmpty {
            return "Looking up titles…"
        }
        if viewModel.items.isEmpty {
            return "No results yet"
        }
        let kind = viewModel.selectedKind == .movie ? "movies" : "series"
        return "\(viewModel.items.count) \(kind)"
    }
}
