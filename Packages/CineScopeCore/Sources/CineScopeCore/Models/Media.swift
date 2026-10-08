import Foundation

public struct Media: Identifiable, Codable, Sendable, Hashable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let voteAverage: Double
    public let voteCount: Int
    public let popularity: Double
    public let releaseDate: String?
    public let mediaKind: MediaKind

    public init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        voteAverage: Double,
        voteCount: Int,
        popularity: Double,
        releaseDate: String?,
        mediaKind: MediaKind
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.popularity = popularity
        self.releaseDate = releaseDate
        self.mediaKind = mediaKind
    }

    public var shortDescription: String {
        let trimmed = overview.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "No description available." }
        if trimmed.count <= 160 { return trimmed }
        let index = trimmed.index(trimmed.startIndex, offsetBy: 157)
        return String(trimmed[..<index]) + "..."
    }
}

struct TMDBMediaDTO: Decodable, Sendable {
    let id: Int
    let title: String?
    let name: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let voteCount: Int?
    let popularity: Double?
    let releaseDate: String?
    let firstAirDate: String?
    let mediaType: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case mediaType = "media_type"
    }

    func asMedia(defaultKind: MediaKind) -> Media {
        let resolvedKind: MediaKind
        if let mediaType, let kind = MediaKind(rawValue: mediaType) {
            resolvedKind = kind
        } else {
            resolvedKind = defaultKind
        }

        return Media(
            id: id,
            title: title ?? name ?? "Untitled",
            overview: overview ?? "",
            posterPath: posterPath,
            backdropPath: backdropPath,
            voteAverage: voteAverage ?? 0,
            voteCount: voteCount ?? 0,
            popularity: popularity ?? 0,
            releaseDate: releaseDate ?? firstAirDate,
            mediaKind: resolvedKind
        )
    }
}
