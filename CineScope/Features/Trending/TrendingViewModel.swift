import Foundation
import Observation
import CineScopeCore

@Observable
@MainActor
final class TrendingViewModel {
    private(set) var items: [Media] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var errorMessage: String?
    var selectedMedia: Media?

    private let repository: any MediaRepository
    private let imagePipeline: ImagePipeline
    private var currentPage = 0
    private var totalPages = 1
    private var loadTask: Task<Void, Never>?

    init(
        repository: any MediaRepository,
        imagePipeline: ImagePipeline
    ) {
        self.repository = repository
        self.imagePipeline = imagePipeline
    }

    var hasMorePages: Bool {
        currentPage < totalPages
    }

    func onAppear() {
        guard items.isEmpty else { return }
        loadInitial()
    }

    func loadInitial() {
        loadTask?.cancel()
        loadTask = Task { await fetch(reset: true) }
    }

    func loadMoreIfNeeded(currentItem: Media?) {
        guard let currentItem else { return }
        guard let index = items.firstIndex(of: currentItem) else { return }
        let thresholdIndex = max(items.count - 4, 0)
        guard index >= thresholdIndex else { return }
        guard hasMorePages, !isLoading, !isLoadingMore else { return }
        loadTask = Task { await fetch(reset: false) }
    }

    func select(_ media: Media) {
        selectedMedia = media
    }

    func prefetchImages(for mediaItems: [Media], pointWidth: CGFloat, scale: CGFloat) {
        let size = PosterImageSize.matching(
            pointWidth: pointWidth,
            scale: scale,
            maximum: .w342
        )
        let paths = mediaItems.compactMap(\.posterPath)
        Task {
            await imagePipeline.prefetch(paths: paths, size: size)
        }
    }

    private func fetch(reset: Bool) async {
        if reset {
            isLoading = true
            currentPage = 0
            totalPages = 1
            errorMessage = nil
        } else {
            isLoadingMore = true
        }

        let nextPage = currentPage + 1
        do {
            let page = try await repository.trendingMovies(page: nextPage)
            if reset {
                items = page.results
            } else {
                let existing = Set(items.map(\.id))
                items.append(contentsOf: page.results.filter { !existing.contains($0.id) })
            }
            currentPage = page.page
            totalPages = page.totalPages
            prefetchImages(for: page.results, pointWidth: 160, scale: 2)
        } catch is CancellationError {
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
        isLoadingMore = false
    }
}
