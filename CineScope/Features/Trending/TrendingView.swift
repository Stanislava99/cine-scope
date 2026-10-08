import SwiftUI
import CineScopeCore

struct TrendingView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var trendingViewModel: TrendingViewModel?
    @State private var searchViewModel: SearchViewModel?

    var body: some View {
        Group {
            if let trendingViewModel, let searchViewModel {
                adaptiveContent(
                    trending: trendingViewModel,
                    search: searchViewModel
                )
            } else {
                ProgressView()
                    .tint(.cinePrimary)
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .cineScreenBackground()
        .task {
            if trendingViewModel == nil {
                trendingViewModel = TrendingViewModel(
                    repository: dependencies.repository,
                    imagePipeline: dependencies.imagePipeline
                )
            }
            if searchViewModel == nil {
                searchViewModel = SearchViewModel(
                    repository: dependencies.repository
                )
            }
            trendingViewModel?.onAppear()
        }
    }

    @ViewBuilder
    private func adaptiveContent(
        trending: TrendingViewModel,
        search: SearchViewModel
    ) -> some View {
        if sizeClass == .regular {
            NavigationSplitView {
                homeColumn(trending: trending, search: search)
            } detail: {
                detailColumn(trending: trending, search: search)
            }
        } else {
            NavigationStack {
                homeColumn(trending: trending, search: search)
            }
        }
    }

    @ViewBuilder
    private func homeColumn(
        trending: TrendingViewModel,
        search: SearchViewModel
    ) -> some View {
        @Bindable var search = search
        @Bindable var trending = trending

        HomeContent(
            trendingViewModel: trending,
            searchViewModel: search
        )
        .navigationTitle("Trending")
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: $search.query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search movies or series"
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    FavoritesView()
                } label: {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(Color.cineFavorite)
                }
                .accessibilityIdentifier("favorites.button")
                .accessibilityLabel("Favorites")
            }
        }
        .navigationDestination(item: $trending.selectedMedia) { media in
            DetailsView(media: media)
        }
        .navigationDestination(item: $search.selectedMedia) { media in
            DetailsView(media: media)
        }
        .refreshable {
            let trimmed = search.query.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                trending.loadInitial()
            }
        }
    }

    @ViewBuilder
    private func detailColumn(
        trending: TrendingViewModel,
        search: SearchViewModel
    ) -> some View {
        if let media = search.selectedMedia ?? trending.selectedMedia {
            DetailsView(media: media)
        } else {
            CineEmptyState(
                title: "Select a title",
                systemImage: "film",
                message: "Pick something from Trending or Search to see the full details."
            )
        }
    }
}

private struct HomeContent: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(FavoritesController.self) private var favorites
    @Environment(\.isSearching) private var isSearching
    @Bindable var trendingViewModel: TrendingViewModel
    @Bindable var searchViewModel: SearchViewModel

    private var showsSearch: Bool {
        isSearching || !searchViewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Group {
            if showsSearch {
                SearchResultsView(viewModel: searchViewModel)
            } else {
                trendingBody
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var trendingBody: some View {
        if trendingViewModel.isLoading && trendingViewModel.items.isEmpty {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(.cinePrimary)
                Text("Loading trending movies…")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.cineSecondaryText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = trendingViewModel.errorMessage, trendingViewModel.items.isEmpty {
            CineEmptyState(
                title: "Unable to load",
                systemImage: "wifi.exclamationmark",
                message: errorMessage,
                accent: .paletteOrange
            )
            .overlay(alignment: .bottom) {
                Button("Retry") { trendingViewModel.loadInitial() }
                    .buttonStyle(.borderedProminent)
                    .tint(.cinePrimary)
                    .padding(.bottom, 40)
            }
        } else {
            MediaMosaicGrid(
                items: trendingViewModel.items,
                favoriteKeys: favorites.favoriteKeys,
                imagePipeline: dependencies.imagePipeline,
                isLoadingMore: trendingViewModel.isLoadingMore,
                onSelect: { trendingViewModel.select($0) },
                onFavorite: { media in
                    Task { await favorites.toggle(media) }
                },
                onNearEnd: { trendingViewModel.loadMoreIfNeeded(currentItem: $0) }
            )
        }
    }
}
