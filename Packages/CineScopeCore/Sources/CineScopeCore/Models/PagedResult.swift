import Foundation

public struct PagedResult<Item: Sendable>: Sendable {
    public let page: Int
    public let totalPages: Int
    public let totalResults: Int
    public let results: [Item]

    public init(page: Int, totalPages: Int, totalResults: Int, results: [Item]) {
        self.page = page
        self.totalPages = totalPages
        self.totalResults = totalResults
        self.results = results
    }

    public var hasMorePages: Bool {
        page < totalPages
    }
}

struct TMDBPagedDTO<DTO: Decodable & Sendable>: Decodable, Sendable {
    let page: Int
    let totalPages: Int
    let totalResults: Int
    let results: [DTO]

    enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case totalResults = "total_results"
        case results
    }
}
