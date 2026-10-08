import Foundation

public struct CastMember: Identifiable, Codable, Sendable, Hashable {
    public let id: Int
    public let name: String
    public let character: String
    public let profilePath: String?
    public let order: Int

    public init(id: Int, name: String, character: String, profilePath: String?, order: Int) {
        self.id = id
        self.name = name
        self.character = character
        self.profilePath = profilePath
        self.order = order
    }
}

public struct CrewMember: Identifiable, Codable, Sendable, Hashable {
    public let id: Int
    public let name: String
    public let job: String
    public let department: String
    public let profilePath: String?

    public init(id: Int, name: String, job: String, department: String, profilePath: String?) {
        self.id = id
        self.name = name
        self.job = job
        self.department = department
        self.profilePath = profilePath
    }
}

public struct Credits: Codable, Sendable, Hashable {
    public let cast: [CastMember]
    public let crew: [CrewMember]

    public init(cast: [CastMember], crew: [CrewMember]) {
        self.cast = cast
        self.crew = crew
    }

    public var directors: [CrewMember] {
        crew.filter { $0.job.caseInsensitiveCompare("Director") == .orderedSame }
    }

    public var writers: [CrewMember] {
        crew.filter {
            $0.department.caseInsensitiveCompare("Writing") == .orderedSame
                || $0.job.localizedCaseInsensitiveContains("Writer")
                || $0.job.localizedCaseInsensitiveContains("Screenplay")
        }
    }
}

struct TMDBCreditsDTO: Decodable, Sendable {
    let cast: [TMDBCastDTO]?
    let crew: [TMDBCrewDTO]?

    func asCredits() -> Credits {
        Credits(
            cast: (cast ?? []).map { $0.asCastMember() },
            crew: (crew ?? []).map { $0.asCrewMember() }
        )
    }
}

struct TMDBCastDTO: Decodable, Sendable {
    let id: Int
    let name: String?
    let character: String?
    let profilePath: String?
    let order: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case profilePath = "profile_path"
        case order
    }

    func asCastMember() -> CastMember {
        CastMember(
            id: id,
            name: name ?? "Unknown",
            character: character ?? "",
            profilePath: profilePath,
            order: order ?? 0
        )
    }
}

struct TMDBCrewDTO: Decodable, Sendable {
    let id: Int
    let name: String?
    let job: String?
    let department: String?
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case job
        case department
        case profilePath = "profile_path"
    }

    func asCrewMember() -> CrewMember {
        CrewMember(
            id: id,
            name: name ?? "Unknown",
            job: job ?? "",
            department: department ?? "",
            profilePath: profilePath
        )
    }
}
