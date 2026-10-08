import Foundation

public enum TMDBEndpoint: Endpoint, Equatable, Sendable {
    case trendingMovies(page: Int)
    case movieDetails(id: Int)
    case tvDetails(id: Int)
    case searchMovies(query: String, page: Int)
    case searchTV(query: String, page: Int)

    public var path: String {
        switch self {
        case .trendingMovies:
            "/3/trending/movie/day"
        case .movieDetails(let id):
            "/3/movie/\(id)"
        case .tvDetails(let id):
            "/3/tv/\(id)"
        case .searchMovies:
            "/3/search/movie"
        case .searchTV:
            "/3/search/tv"
        }
    }

    public var queryItems: [URLQueryItem] {
        switch self {
        case .trendingMovies(let page):
            [URLQueryItem(name: "page", value: String(page))]
        case .movieDetails, .tvDetails:
            [URLQueryItem(name: "append_to_response", value: "credits")]
        case .searchMovies(let query, let page), .searchTV(let query, let page):
            [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "include_adult", value: "false")
            ]
        }
    }
}
