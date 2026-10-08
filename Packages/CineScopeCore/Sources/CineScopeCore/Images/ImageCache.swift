import Foundation

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#else
public struct PlatformImage: Sendable {
    public let data: Data
    public init(data: Data) { self.data = data }
}
#endif

public actor ImageMemoryCache {
    private let cache = NSCache<NSString, CacheBox>()

    public init(countLimit: Int = 200) {
        cache.countLimit = countLimit
    }

    public func image(for key: String) -> PlatformImage? {
        cache.object(forKey: key as NSString)?.image
    }

    public func store(_ image: PlatformImage, for key: String) {
        cache.setObject(CacheBox(image: image), forKey: key as NSString)
    }
}

public actor ImageDiskCache {
    private let directory: URL
    private let fileManager: FileManager

    public init(directory: URL? = nil, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        if let directory {
            self.directory = directory
        } else {
            let base = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
                ?? fileManager.temporaryDirectory
            self.directory = base.appendingPathComponent("CineScopeImageCache", isDirectory: true)
        }
        try? fileManager.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    public func data(for key: String) -> Data? {
        let url = fileURL(for: key)
        return try? Data(contentsOf: url)
    }

    public func store(_ data: Data, for key: String) {
        let url = fileURL(for: key)
        try? data.write(to: url, options: .atomic)
    }

    private func fileURL(for key: String) -> URL {
        let safe = key
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            ?? String(key.hashValue)
        return directory.appendingPathComponent(safe)
    }
}

private final class CacheBox: NSObject, @unchecked Sendable {
    let image: PlatformImage
    init(image: PlatformImage) { self.image = image }
}
