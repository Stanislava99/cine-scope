import Foundation

public struct MovieDetails: Identifiable, Codable, Sendable, Hashable {
    public let id: Int
    public let title: String
    public let overview: String
    public let tagline: String?
    public let posterPath: String?
    public let backdropPath: String?
    public let voteAverage: Double
    public let voteCount: Int
    public let popularity: Double
    public let releaseDate: String?
    public let runtime: Int?
    public let status: String?
    public let budget: Int
    public let revenue: Int
    public let genres: [Genre]
    public let credits: Credits
    public let homepage: String?
    public let originalLanguage: String?

    public init(
        id: Int,
        title: String,
        overview: String,
        tagline: String?,
        posterPath: String?,
        backdropPath: String?,
        voteAverage: Double,
        voteCount: Int,
        popularity: Double,
        releaseDate: String?,
        runtime: Int?,
        status: String?,
        budget: Int,
        revenue: Int,
        genres: [Genre],
        credits: Credits,
        homepage: String?,
        originalLanguage: String?
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.tagline = tagline
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.popularity = popularity
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.status = status
        self.budget = budget
        self.revenue = revenue
        self.genres = genres
        self.credits = credits
        self.homepage = homepage
        self.originalLanguage = originalLanguage
    }

    public var asMedia: Media {
        Media(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            voteAverage: voteAverage,
            voteCount: voteCount,
            popularity: popularity,
            releaseDate: releaseDate,
            mediaKind: .movie
        )
    }
}

struct TMDBMovieDetailsDTO: Decodable, Sendable {
    let id: Int
    let title: String?
    let overview: String?
    let tagline: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let voteCount: Int?
    let popularity: Double?
    let releaseDate: String?
    let runtime: Int?
    let status: String?
    let budget: Int?
    let revenue: Int?
    let genres: [Genre]?
    let credits: TMDBCreditsDTO?
    let homepage: String?
    let originalLanguage: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case tagline
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
        case releaseDate = "release_date"
        case runtime
        case status
        case budget
        case revenue
        case genres
        case credits
        case homepage
        case originalLanguage = "original_language"
    }

    func asMovieDetails() -> MovieDetails {
        MovieDetails(
            id: id,
            title: title ?? "Untitled",
            overview: overview ?? "",
            tagline: tagline,
            posterPath: posterPath,
            backdropPath: backdropPath,
            voteAverage: voteAverage ?? 0,
            voteCount: voteCount ?? 0,
            popularity: popularity ?? 0,
            releaseDate: releaseDate,
            runtime: runtime,
            status: status,
            budget: budget ?? 0,
            revenue: revenue ?? 0,
            genres: genres ?? [],
            credits: credits?.asCredits() ?? Credits(cast: [], crew: []),
            homepage: homepage,
            originalLanguage: originalLanguage
        )
    }
}
