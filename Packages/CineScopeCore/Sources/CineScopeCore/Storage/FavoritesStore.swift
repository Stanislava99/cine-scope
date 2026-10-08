import Foundation

public actor FavoritesStore {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var favoritesByKey: [String: Media]

    public init(directory: URL? = nil, fileManager: FileManager = .default) {
        let base: URL
        if let directory {
            base = directory
        } else {
            base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? fileManager.temporaryDirectory
        }
        try? fileManager.createDirectory(at: base, withIntermediateDirectories: true)
        let fileURL = base.appendingPathComponent("favorites.json")
        self.fileURL = fileURL

        if let data = try? Data(contentsOf: fileURL),
           let stored = try? JSONDecoder().decode([Media].self, from: data) {
            favoritesByKey = Dictionary(uniqueKeysWithValues: stored.map { (Self.key(for: $0), $0) })
        } else {
            favoritesByKey = [:]
        }
    }

    public func all() -> [Media] {
        favoritesByKey.values.sorted { lhs, rhs in
            lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }

    public func contains(_ media: Media) -> Bool {
        favoritesByKey[Self.key(for: media)] != nil
    }

    public func contains(id: Int, kind: MediaKind) -> Bool {
        favoritesByKey[Self.key(id: id, kind: kind)] != nil
    }

    public func favoriteIDs() -> Set<String> {
        Set(favoritesByKey.keys)
    }

    @discardableResult
    public func toggle(_ media: Media) -> Bool {
        let key = Self.key(for: media)
        if favoritesByKey[key] != nil {
            favoritesByKey.removeValue(forKey: key)
            persist()
            return false
        } else {
            favoritesByKey[key] = media
            persist()
            return true
        }
    }

    public func add(_ media: Media) {
        favoritesByKey[Self.key(for: media)] = media
        persist()
    }

    public func remove(_ media: Media) {
        favoritesByKey.removeValue(forKey: Self.key(for: media))
        persist()
    }

    public static func key(for media: Media) -> String {
        key(id: media.id, kind: media.mediaKind)
    }

    public static func key(id: Int, kind: MediaKind) -> String {
        "\(kind.rawValue)-\(id)"
    }

    private func persist() {
        let values = Array(favoritesByKey.values)
        guard let data = try? encoder.encode(values) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
