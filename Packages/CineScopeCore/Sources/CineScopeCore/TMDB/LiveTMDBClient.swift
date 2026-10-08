import Foundation

public struct LiveTMDBClient: TMDBClient {
    private let httpClient: any HTTPClient
    private let configuration: AppConfiguration
    private let decoder: JSONDecoder

    public init(
        httpClient: any HTTPClient = URLSessionHTTPClient(),
        configuration: AppConfiguration,
        decoder: JSONDecoder = .tmdb
    ) {
        self.httpClient = httpClient
        self.configuration = configuration
        self.decoder = decoder
    }

    public func trendingMovies(page: Int) async throws -> PagedResult<Media> {
        try await fetchPagedMedia(
            endpoint: .trendingMovies(page: page),
            defaultKind: .movie
        )
    }

    public func movieDetails(id: Int) async throws -> MovieDetails {
        let dto: TMDBMovieDetailsDTO = try await fetch(endpoint: .movieDetails(id: id))
        return dto.asMovieDetails()
    }

    public func tvDetails(id: Int) async throws -> TVDetails {
        let dto: TMDBTVDetailsDTO = try await fetch(endpoint: .tvDetails(id: id))
        return dto.asTVDetails()
    }

    public func search(query: String, kind: MediaKind, page: Int) async throws -> PagedResult<Media> {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw NetworkError.emptyQuery }

        let endpoint: TMDBEndpoint = switch kind {
        case .movie:
            .searchMovies(query: trimmed, page: page)
        case .tv:
            .searchTV(query: trimmed, page: page)
        }

        return try await fetchPagedMedia(endpoint: endpoint, defaultKind: kind)
    }

    private func fetchPagedMedia(
        endpoint: TMDBEndpoint,
        defaultKind: MediaKind
    ) async throws -> PagedResult<Media> {
        let dto: TMDBPagedDTO<TMDBMediaDTO> = try await fetch(endpoint: endpoint)
        return PagedResult(
            page: dto.page,
            totalPages: dto.totalPages,
            totalResults: dto.totalResults,
            results: dto.results.map { $0.asMedia(defaultKind: defaultKind) }
        )
    }

    private func fetch<T: Decodable & Sendable>(endpoint: TMDBEndpoint) async throws -> T {
        guard let token = configuration.accessToken, !token.isEmpty else {
            throw NetworkError.missingAccessToken
        }

        let request = try endpoint.makeRequest(
            baseURL: configuration.apiBaseURL,
            accessToken: token
        )
        let (data, response) = try await httpClient.data(for: request)

        guard (200...299).contains(response.statusCode) else {
            throw NetworkError.httpStatus(response.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }
}
