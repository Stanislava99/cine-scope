import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct ImageRequest: Sendable, Hashable {
    public let path: String
    public let size: PosterImageSize

    public init(path: String, size: PosterImageSize) {
        self.path = path
        self.size = size
    }

    public var cacheKey: String {
        "\(size.rawValue):\(path)"
    }
}

public actor ImagePipeline {
    private let httpClient: any HTTPClient
    private let urlBuilder: ImageURLBuilder
    private let memoryCache: ImageMemoryCache
    private let diskCache: ImageDiskCache
    private let maxConcurrentDownloads: Int
    private var inFlight: [String: Task<PlatformImage, Error>] = [:]
    private var activeDownloads = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []

    public init(
        httpClient: any HTTPClient = URLSessionHTTPClient.images,
        urlBuilder: ImageURLBuilder = ImageURLBuilder(),
        memoryCache: ImageMemoryCache = ImageMemoryCache(),
        diskCache: ImageDiskCache,
        maxConcurrentDownloads: Int = 8
    ) {
        self.httpClient = httpClient
        self.urlBuilder = urlBuilder
        self.memoryCache = memoryCache
        self.diskCache = diskCache
        self.maxConcurrentDownloads = max(1, maxConcurrentDownloads)
    }

    public func cachedImage(for request: ImageRequest) async -> PlatformImage? {
        if let cached = await memoryCache.image(for: request.cacheKey) {
            return cached
        }
        if let data = await diskCache.data(for: request.cacheKey),
           let image = Self.makeImage(from: data) {
            await memoryCache.store(image, for: request.cacheKey)
            return image
        }
        return nil
    }

    public func image(for request: ImageRequest) async throws -> PlatformImage {
        if let cached = await cachedImage(for: request) {
            return cached
        }

        if let existing = inFlight[request.cacheKey] {
            return try await existing.value
        }

        let task = Task { [weak self] in
            guard let self else { throw NetworkError.cancelled }
            return try await self.download(request)
        }
        inFlight[request.cacheKey] = task

        do {
            let image = try await task.value
            inFlight[request.cacheKey] = nil
            return image
        } catch {
            inFlight[request.cacheKey] = nil
            throw error
        }
    }

    public func prefetch(paths: [String], size: PosterImageSize) {
        for path in paths {
            let request = ImageRequest(path: path, size: size)
            Task { try? await image(for: request) }
        }
    }

    private func download(_ request: ImageRequest) async throws -> PlatformImage {
        await acquireSlot()
        defer { releaseSlot() }

        guard let url = urlBuilder.url(path: request.path, size: request.size) else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("image/*", forHTTPHeaderField: "Accept")
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        let (data, response) = try await httpClient.data(for: urlRequest)
        guard (200...299).contains(response.statusCode) else {
            throw NetworkError.httpStatus(response.statusCode)
        }
        guard let image = Self.makeImage(from: data) else {
            throw NetworkError.decodingFailed("Unable to create image from data.")
        }

        await diskCache.store(data, for: request.cacheKey)
        await memoryCache.store(image, for: request.cacheKey)
        return image
    }

    private func acquireSlot() async {
        if activeDownloads < maxConcurrentDownloads {
            activeDownloads += 1
            return
        }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
        activeDownloads += 1
    }

    private func releaseSlot() {
        activeDownloads = max(0, activeDownloads - 1)
        if !waiters.isEmpty {
            let next = waiters.removeFirst()
            next.resume()
        }
    }

    private static func makeImage(from data: Data) -> PlatformImage? {
        #if canImport(UIKit)
        return UIImage(data: data)
        #elseif canImport(AppKit)
        return NSImage(data: data)
        #else
        return PlatformImage(data: data)
        #endif
    }
}
