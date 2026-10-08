import Foundation
import Observation
import CineScopeCore

@Observable
@MainActor
final class FavoritesViewModel {
    var selectedMedia: Media?

    private let favorites: FavoritesController

    init(favorites: FavoritesController) {
        self.favorites = favorites
    }

    var items: [Media] {
        favorites.items
    }

    func select(_ media: Media) {
        selectedMedia = media
    }

    func remove(_ media: Media) {
        Task {
            await favorites.remove(media)
        }
    }
}
