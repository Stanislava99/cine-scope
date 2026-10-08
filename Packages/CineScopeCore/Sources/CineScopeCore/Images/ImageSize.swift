import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#else
public typealias CGFloat = Double
#endif

public enum PosterImageSize: String, Sendable, CaseIterable {
    case w92
    case w154
    case w185
    case w342
    case w500
    case w780
    case original

    public var pixelWidth: Int {
        switch self {
        case .w92: 92
        case .w154: 154
        case .w185: 185
        case .w342: 342
        case .w500: 500
        case .w780: 780
        case .original: Int.max
        }
    }

    public static func matching(
        pointWidth: CGFloat,
        scale: CGFloat,
        maximum: PosterImageSize = .w780
    ) -> PosterImageSize {
        let required = Int(ceil(pointWidth * max(scale, 1)))
        let candidates = PosterImageSize.allCases
            .filter { $0 != .original && $0.pixelWidth <= maximum.pixelWidth }
        return candidates.first(where: { $0.pixelWidth >= required })
            ?? candidates.last
            ?? .w342
    }

    public var lowResPlaceholder: PosterImageSize {
        switch self {
        case .w92, .w154:
            .w92
        case .w185, .w342:
            .w92
        case .w500, .w780, .original:
            .w185
        }
    }
}
