import Foundation
import Observation
import CineScopeCore

@Observable
@MainActor
final class FavoritesController {
    private(set) var items: [Media] = []
    private(set) var favoriteKeys: Set<String> = []

    private let store: FavoritesStore

    init(store: FavoritesStore) {
        self.store = store
    }

    func load() async {
        await refresh()
    }

    func isFavorite(_ media: Media) -> Bool {
        favoriteKeys.contains(FavoritesStore.key(for: media))
    }

    @discardableResult
    func toggle(_ media: Media) async -> Bool {
        let isFavorite = await store.toggle(media)
        await refresh()
        return isFavorite
    }

    func remove(_ media: Media) async {
        await store.remove(media)
        await refresh()
    }

    private func refresh() async {
        items = await store.all()
        favoriteKeys = await store.favoriteIDs()
    }
}
