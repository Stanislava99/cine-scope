import Foundation
import Observation
import CineScopeCore

@Observable
@MainActor
final class DetailsViewModel {
    private(set) var details: MediaDetails?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let media: Media
    private let repository: any MediaRepository
    private let favorites: FavoritesController

    init(
        media: Media,
        repository: any MediaRepository,
        favorites: FavoritesController
    ) {
        self.media = media
        self.repository = repository
        self.favorites = favorites
    }

    var isFavorite: Bool {
        favorites.isFavorite(media)
    }

    func load() {
        Task { await fetch() }
    }

    func toggleFavorite() {
        Task { await favorites.toggle(media) }
    }

    private func fetch() async {
        isLoading = true
        errorMessage = nil
        do {
            details = try await repository.details(for: media)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
