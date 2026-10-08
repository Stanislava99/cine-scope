import Foundation
import Observation
import CineScopeCore

@Observable
@MainActor
final class AppDependencies {
    let configuration: AppConfiguration
    let repository: any MediaRepository
    let favorites: FavoritesController
    let imagePipeline: ImagePipeline
    let imageURLBuilder: ImageURLBuilder

    init(
        configuration: AppConfiguration,
        repository: any MediaRepository,
        favorites: FavoritesController,
        imagePipeline: ImagePipeline,
        imageURLBuilder: ImageURLBuilder
    ) {
        self.configuration = configuration
        self.repository = repository
        self.favorites = favorites
        self.imagePipeline = imagePipeline
        self.imageURLBuilder = imageURLBuilder
    }

    static func makeDefault() -> AppDependencies {
        let bundle = Bundle.main
        let environmentName = bundle.object(forInfoDictionaryKey: "AppEnvironment") as? String
        let token = bundle.object(forInfoDictionaryKey: "TMDBAccessToken") as? String
        let configuration = AppConfiguration.resolve(
            environmentName: environmentName,
            accessToken: token
        )

        let client = TMDBClientFactory.make(configuration: configuration)
        let store = MediaStore()
        let favoritesStore = FavoritesStore()
        let favorites = FavoritesController(store: favoritesStore)
        let diskCache = ImageDiskCache()
        let pipeline = ImagePipeline(diskCache: diskCache)
        let repository = LiveMediaRepository(client: client, store: store)

        return AppDependencies(
            configuration: configuration,
            repository: repository,
            favorites: favorites,
            imagePipeline: pipeline,
            imageURLBuilder: ImageURLBuilder(baseURL: configuration.imageBaseURL)
        )
    }
}
