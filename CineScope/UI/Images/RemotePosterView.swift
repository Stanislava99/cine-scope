import SwiftUI
import CineScopeCore

struct RemotePosterView: View {
    let path: String?
    let imagePipeline: ImagePipeline
    var cornerRadius: CGFloat = CineTheme.cardCornerRadius
    var maxSize: PosterImageSize = .w780
    var loadsProgressively: Bool = true

    @Environment(\.displayScale) private var displayScale
    @State private var image: Image?
    @State private var isLoading = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.cineCard
                if let image {
                    image
                        .resizable()
                        .scaledToFill()
                        .transition(.opacity)
                } else if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "film")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .task(id: taskID(for: proxy.size)) {
                await load(for: proxy.size)
            }
        }
    }

    private func taskID(for size: CGSize) -> String {
        "\(path ?? "")-\(Int(size.width))-\(maxSize.rawValue)-\(loadsProgressively)"
    }

    @MainActor
    private func load(for size: CGSize) async {
        guard let path else {
            image = nil
            return
        }

        let target = PosterImageSize.matching(
            pointWidth: size.width,
            scale: displayScale,
            maximum: maxSize
        )
        let finalRequest = ImageRequest(path: path, size: target)

        if let cached = await imagePipeline.cachedImage(for: finalRequest) {
            image = Image(platformImage: cached)
            isLoading = false
            return
        }

        isLoading = image == nil

        if loadsProgressively {
            let lowRequest = ImageRequest(path: path, size: target.lowResPlaceholder)
            if let low = await imagePipeline.cachedImage(for: lowRequest) {
                image = Image(platformImage: low)
                isLoading = false
            } else if let low = try? await imagePipeline.image(for: lowRequest) {
                image = Image(platformImage: low)
                isLoading = false
            }
        }

        if let final = try? await imagePipeline.image(for: finalRequest) {
            withAnimation(.easeInOut(duration: 0.2)) {
                image = Image(platformImage: final)
            }
        }
        isLoading = false
    }
}

private extension Image {
    init(platformImage: PlatformImage) {
        #if canImport(UIKit)
        self.init(uiImage: platformImage)
        #elseif canImport(AppKit)
        self.init(nsImage: platformImage)
        #else
        self.init(systemName: "film")
        #endif
    }
}
