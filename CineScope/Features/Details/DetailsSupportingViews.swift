import SwiftUI
import CineScopeCore

struct DetailsHeroView: View {
    let media: Media
    let details: MediaDetails?
    let imagePipeline: ImagePipeline
    let appeared: Bool

    private var backdrop: String? {
        details?.backdropPath ?? media.backdropPath ?? details?.posterPath ?? media.posterPath
    }

    private var poster: String? {
        details?.posterPath ?? media.posterPath
    }

    private var title: String {
        details?.title ?? media.title
    }

    private var tagline: String? {
        details?.tagline
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RemotePosterView(
                path: backdrop,
                imagePipeline: imagePipeline,
                cornerRadius: 0,
                maxSize: .w780,
                loadsProgressively: true
            )
            .frame(height: 380)
            .overlay {
                LinearGradient(
                    colors: [
                        Color.cineBackground.opacity(0.15),
                        Color.cineBackground.opacity(0.55),
                        Color.cineBackground
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [Color.black.opacity(0.45), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
            }

            HStack(alignment: .bottom, spacing: 16) {
                RemotePosterView(
                    path: poster,
                    imagePipeline: imagePipeline,
                    cornerRadius: 14,
                    maxSize: .w342,
                    loadsProgressively: false
                )
                .frame(width: 118, height: 176)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.45), radius: 18, y: 10)
                .scaleEffect(appeared ? 1 : 0.92)
                .opacity(appeared ? 1 : 0)

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundStyle(Color.cinePrimaryText)
                        .lineLimit(3)

                    if let tagline, !tagline.isEmpty {
                        Text(tagline)
                            .font(.subheadline.italic())
                            .foregroundStyle(Color.cineSecondaryText)
                            .lineLimit(3)
                    }

                    Text(media.mediaKind == .movie ? "Movie" : "Series")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.cinePrimaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(CineGradient.primaryBlue, in: Capsule())
                }
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }
}

struct ExpandableOverview: View {
    let text: String
    @Binding var isExpanded: Bool
    @State private var fullHeight: CGFloat = 0
    @State private var limitedHeight: CGFloat = 0

    private var canExpand: Bool {
        fullHeight > limitedHeight + 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .font(.body)
                .foregroundStyle(Color.cineSecondaryText)
                .lineSpacing(5)
                .lineLimit(isExpanded ? nil : 3)

            if canExpand || isExpanded {
                Button(isExpanded ? "See less" : "See more") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.cinePrimary)
                .buttonStyle(.plain)
            }
        }
        .background {
            ZStack {
                Text(text)
                    .font(.body)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .overlay {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { fullHeight = proxy.size.height }
                                .onChange(of: proxy.size.height) { _, newValue in
                                    fullHeight = newValue
                                }
                        }
                    }

                Text(text)
                    .font(.body)
                    .lineSpacing(5)
                    .lineLimit(3)
                    .hidden()
                    .overlay {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { limitedHeight = proxy.size.height }
                                .onChange(of: proxy.size.height) { _, newValue in
                                    limitedHeight = newValue
                                }
                        }
                    }
            }
            .allowsHitTesting(false)
        }
    }
}

struct CastAvatar: View {
    let path: String?
    let imagePipeline: ImagePipeline

    var body: some View {
        RemotePosterView(
            path: path,
            imagePipeline: imagePipeline,
            cornerRadius: 34,
            maxSize: .w185,
            loadsProgressively: false
        )
        .frame(width: 68, height: 68)
        .clipShape(Circle())
        .overlay {
            Circle().stroke(CineGradient.primaryBlue.opacity(0.55), lineWidth: 1.5)
        }
    }
}
