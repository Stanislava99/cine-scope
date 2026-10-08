import Foundation

public struct TVDetails: Identifiable, Codable, Sendable, Hashable {
    public let id: Int
    public let name: String
    public let overview: String
    public let tagline: String?
    public let posterPath: String?
    public let backdropPath: String?
    public let voteAverage: Double
    public let voteCount: Int
    public let popularity: Double
    public let firstAirDate: String?
    public let numberOfSeasons: Int
    public let numberOfEpisodes: Int
    public let status: String?
    public let genres: [Genre]
    public let credits: Credits
    public let homepage: String?
    public let originalLanguage: String?

    public init(
        id: Int,
        name: String,
        overview: String,
        tagline: String?,
        posterPath: String?,
        backdropPath: String?,
        voteAverage: Double,
        voteCount: Int,
        popularity: Double,
        firstAirDate: String?,
        numberOfSeasons: Int,
        numberOfEpisodes: Int,
        status: String?,
        genres: [Genre],
        credits: Credits,
        homepage: String?,
        originalLanguage: String?
    ) {
        self.id = id
        self.name = name
        self.overview = overview
        self.tagline = tagline
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.popularity = popularity
        self.firstAirDate = firstAirDate
        self.numberOfSeasons = numberOfSeasons
        self.numberOfEpisodes = numberOfEpisodes
        self.status = status
        self.genres = genres
        self.credits = credits
        self.homepage = homepage
        self.originalLanguage = originalLanguage
    }

    public var asMedia: Media {
        Media(
            id: id,
            title: name,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            voteAverage: voteAverage,
            voteCount: voteCount,
            popularity: popularity,
            releaseDate: firstAirDate,
            mediaKind: .tv
        )
    }
}

struct TMDBTVDetailsDTO: Decodable, Sendable {
    let id: Int
    let name: String?
    let overview: String?
    let tagline: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let voteCount: Int?
    let popularity: Double?
    let firstAirDate: String?
    let numberOfSeasons: Int?
    let numberOfEpisodes: Int?
    let status: String?
    let genres: [Genre]?
    let credits: TMDBCreditsDTO?
    let homepage: String?
    let originalLanguage: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case overview
        case tagline
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
        case firstAirDate = "first_air_date"
        case numberOfSeasons = "number_of_seasons"
        case numberOfEpisodes = "number_of_episodes"
        case status
        case genres
        case credits
        case homepage
        case originalLanguage = "original_language"
    }

    func asTVDetails() -> TVDetails {
        TVDetails(
            id: id,
            name: name ?? "Untitled",
            overview: overview ?? "",
            tagline: tagline,
            posterPath: posterPath,
            backdropPath: backdropPath,
            voteAverage: voteAverage ?? 0,
            voteCount: voteCount ?? 0,
            popularity: popularity ?? 0,
            firstAirDate: firstAirDate,
            numberOfSeasons: numberOfSeasons ?? 0,
            numberOfEpisodes: numberOfEpisodes ?? 0,
            status: status,
            genres: genres ?? [],
            credits: credits?.asCredits() ?? Credits(cast: [], crew: []),
            homepage: homepage,
            originalLanguage: originalLanguage
        )
    }
}

public enum MediaDetails: Sendable, Hashable {
    case movie(MovieDetails)
    case tv(TVDetails)

    public var id: Int {
        switch self {
        case .movie(let details): details.id
        case .tv(let details): details.id
        }
    }

    public var title: String {
        switch self {
        case .movie(let details): details.title
        case .tv(let details): details.name
        }
    }

    public var overview: String {
        switch self {
        case .movie(let details): details.overview
        case .tv(let details): details.overview
        }
    }

    public var tagline: String? {
        switch self {
        case .movie(let details): details.tagline
        case .tv(let details): details.tagline
        }
    }

    public var posterPath: String? {
        switch self {
        case .movie(let details): details.posterPath
        case .tv(let details): details.posterPath
        }
    }

    public var backdropPath: String? {
        switch self {
        case .movie(let details): details.backdropPath
        case .tv(let details): details.backdropPath
        }
    }

    public var voteAverage: Double {
        switch self {
        case .movie(let details): details.voteAverage
        case .tv(let details): details.voteAverage
        }
    }

    public var voteCount: Int {
        switch self {
        case .movie(let details): details.voteCount
        case .tv(let details): details.voteCount
        }
    }

    public var genres: [Genre] {
        switch self {
        case .movie(let details): details.genres
        case .tv(let details): details.genres
        }
    }

    public var credits: Credits {
        switch self {
        case .movie(let details): details.credits
        case .tv(let details): details.credits
        }
    }

    public var asMedia: Media {
        switch self {
        case .movie(let details): details.asMedia
        case .tv(let details): details.asMedia
        }
    }
}
