import Foundation
import Observation
import CineScopeCore

@Observable
@MainActor
final class SearchViewModel {
    var query = "" {
        didSet { scheduleSearch() }
    }

    var selectedKind: MediaKind = .movie {
        didSet {
            items = []
            currentPage = 0
            totalPages = 1
            scheduleSearch()
        }
    }

    private(set) var items: [Media] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var errorMessage: String?
    var selectedMedia: Media?

    private let repository: any MediaRepository
    private let debouncer = Debouncer(milliseconds: 350)
    private var currentPage = 0
    private var totalPages = 1
    private var activeQuery = ""

    init(repository: any MediaRepository) {
        self.repository = repository
    }

    var hasMorePages: Bool {
        currentPage < totalPages
    }

    func loadMoreIfNeeded(currentItem: Media?) {
        guard let currentItem else { return }
        guard let index = items.firstIndex(of: currentItem) else { return }
        guard index >= max(items.count - 4, 0) else { return }
        guard hasMorePages, !isLoading, !isLoadingMore else { return }
        Task { await fetch(reset: false) }
    }

    func select(_ media: Media) {
        selectedMedia = media
    }

    private func scheduleSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            Task { await debouncer.cancel() }
            items = []
            errorMessage = nil
            activeQuery = ""
            currentPage = 0
            totalPages = 1
            return
        }

        Task {
            await debouncer.debounce { [weak self] in
                await self?.performSearch(query: trimmed)
            }
        }
    }

    private func performSearch(query: String) async {
        activeQuery = query
        await fetch(reset: true)
    }

    private func fetch(reset: Bool) async {
        let querySnapshot = activeQuery
        guard !querySnapshot.isEmpty else { return }

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
            let page = try await repository.search(
                query: querySnapshot,
                kind: selectedKind,
                page: nextPage
            )
            guard querySnapshot == activeQuery else { return }
            if reset {
                items = page.results
            } else {
                let existing = Set(items.map(\.id))
                items.append(contentsOf: page.results.filter { !existing.contains($0.id) })
            }
            currentPage = page.page
            totalPages = page.totalPages
        } catch is CancellationError {
        } catch let error as NetworkError where error == .cancelled {
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
        isLoadingMore = false
    }
}
