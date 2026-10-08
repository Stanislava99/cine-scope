import Foundation

public struct FixtureTMDBClient: TMDBClient {
    private let bundle: Bundle
    private let decoder: JSONDecoder
    private let artificialDelayNanoseconds: UInt64

    public init(
        bundle: Bundle? = nil,
        decoder: JSONDecoder = .tmdb,
        artificialDelayNanoseconds: UInt64 = 150_000_000
    ) {
        self.bundle = bundle ?? Bundle.module
        self.decoder = decoder
        self.artificialDelayNanoseconds = artificialDelayNanoseconds
    }

    public func trendingMovies(page: Int) async throws -> PagedResult<Media> {
        try await delayIfNeeded()
        let dto: TMDBPagedDTO<TMDBMediaDTO> = try load("trending_movies")
        let pageSize = 10
        let start = max(0, (page - 1) * pageSize)
        let slice = Array(dto.results.dropFirst(start).prefix(pageSize))
        let mapped = slice.map { $0.asMedia(defaultKind: .movie) }
        let totalPages = max(1, Int(ceil(Double(dto.results.count) / Double(pageSize))))
        return PagedResult(
            page: page,
            totalPages: totalPages,
            totalResults: dto.results.count,
            results: mapped
        )
    }

    public func movieDetails(id: Int) async throws -> MovieDetails {
        try await delayIfNeeded()
        let dto: TMDBMovieDetailsDTO = try load("movie_details")
        var details = dto.asMovieDetails()
        if details.id != id {
            details = MovieDetails(
                id: id,
                title: details.title,
                overview: details.overview,
                tagline: details.tagline,
                posterPath: details.posterPath,
                backdropPath: details.backdropPath,
                voteAverage: details.voteAverage,
                voteCount: details.voteCount,
                popularity: details.popularity,
                releaseDate: details.releaseDate,
                runtime: details.runtime,
                status: details.status,
                budget: details.budget,
                revenue: details.revenue,
                genres: details.genres,
                credits: details.credits,
                homepage: details.homepage,
                originalLanguage: details.originalLanguage
            )
        }
        return details
    }

    public func tvDetails(id: Int) async throws -> TVDetails {
        try await delayIfNeeded()
        let dto: TMDBTVDetailsDTO = try load("tv_details")
        var details = dto.asTVDetails()
        if details.id != id {
            details = TVDetails(
                id: id,
                name: details.name,
                overview: details.overview,
                tagline: details.tagline,
                posterPath: details.posterPath,
                backdropPath: details.backdropPath,
                voteAverage: details.voteAverage,
                voteCount: details.voteCount,
                popularity: details.popularity,
                firstAirDate: details.firstAirDate,
                numberOfSeasons: details.numberOfSeasons,
                numberOfEpisodes: details.numberOfEpisodes,
                status: details.status,
                genres: details.genres,
                credits: details.credits,
                homepage: details.homepage,
                originalLanguage: details.originalLanguage
            )
        }
        return details
    }

    public func search(query: String, kind: MediaKind, page: Int) async throws -> PagedResult<Media> {
        try await delayIfNeeded()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw NetworkError.emptyQuery }

        let fileName = kind == .movie ? "search_movies" : "search_tv"
        let dto: TMDBPagedDTO<TMDBMediaDTO> = try load(fileName)
        let filtered = dto.results.filter { item in
            let title = (item.title ?? item.name ?? "").lowercased()
            return title.contains(trimmed.lowercased())
        }
        let source = filtered.isEmpty ? dto.results : filtered
        let pageSize = 10
        let start = max(0, (page - 1) * pageSize)
        let slice = Array(source.dropFirst(start).prefix(pageSize))
        let totalPages = max(1, Int(ceil(Double(source.count) / Double(pageSize))))

        return PagedResult(
            page: page,
            totalPages: totalPages,
            totalResults: source.count,
            results: slice.map { $0.asMedia(defaultKind: kind) }
        )
    }

    private func load<T: Decodable>(_ name: String) throws -> T {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw NetworkError.decodingFailed("Missing fixture \(name).json")
        }
        let data = try Data(contentsOf: url)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }

    private func delayIfNeeded() async throws {
        guard artificialDelayNanoseconds > 0 else { return }
        try await Task.sleep(nanoseconds: artificialDelayNanoseconds)
    }
}
