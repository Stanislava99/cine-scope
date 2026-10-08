import SwiftUI
import CineScopeCore

struct DetailsView: View {
    @Environment(AppDependencies.self) private var dependencies
    let media: Media
    @State private var viewModel: DetailsViewModel?
    @State private var appeared = false
    @State private var isOverviewExpanded = false

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                ProgressView()
                    .tint(.cinePrimary)
            }
        }
        .cineScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            if viewModel == nil {
                viewModel = DetailsViewModel(
                    media: media,
                    repository: dependencies.repository,
                    favorites: dependencies.favorites
                )
            }
            viewModel?.load()
            withAnimation(.easeOut(duration: 0.55)) {
                appeared = true
            }
        }
    }

    @ViewBuilder
    private func content(_ viewModel: DetailsViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                DetailsHeroView(
                    media: media,
                    details: viewModel.details,
                    imagePipeline: dependencies.imagePipeline,
                    appeared: appeared
                )

                if viewModel.isLoading && viewModel.details == nil {
                    ProgressView()
                        .tint(.cinePrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 48)
                } else if let errorMessage = viewModel.errorMessage, viewModel.details == nil {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(Color.palettePink)
                        .padding(24)
                } else if let details = viewModel.details {
                    detailsBody(details)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 18)
                } else {
                    fallbackBody
                }
            }
            .padding(.bottom, 40)
        }
        .ignoresSafeArea(edges: .top)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        viewModel.toggleFavorite()
                    }
                } label: {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .symbolEffect(.bounce, value: viewModel.isFavorite)
                        .foregroundStyle(viewModel.isFavorite ? Color.cineFavorite : Color.cinePrimaryText)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityIdentifier("details.favorite.button")
            }
        }
    }

    private var fallbackBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(media.overview)
                .font(.body)
                .foregroundStyle(Color.cineSecondaryText)
                .lineSpacing(4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    @ViewBuilder
    private func detailsBody(_ details: MediaDetails) -> some View {
        VStack(alignment: .leading, spacing: 28) {
            statsStrip(details)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            if !details.genres.isEmpty {
                genresRow(details.genres)
            }

            section(title: "Overview") {
                ExpandableOverview(
                    text: details.overview.isEmpty ? "No overview available." : details.overview,
                    isExpanded: $isOverviewExpanded
                )
            }

            crewStrip(details.credits)

            if !details.credits.cast.isEmpty {
                castSection(details.credits.cast)
            }

            factsSection(details)
        }
    }

    @ViewBuilder
    private func statsStrip(_ details: MediaDetails) -> some View {
        HStack(spacing: 20) {
            CircularRatingView(value: details.voteAverage, size: 72)

            VStack(alignment: .leading, spacing: 10) {
                statLine(
                    icon: "hand.thumbsup.fill",
                    tint: .paletteTeal,
                    title: "Votes",
                    value: formattedCount(details.voteCount)
                )

                switch details {
                case .movie(let movie):
                    if let runtime = movie.runtime {
                        statLine(
                            icon: "clock.fill",
                            tint: .paletteBlue,
                            title: "Runtime",
                            value: formatRuntime(runtime)
                        )
                    }
                    if let date = movie.releaseDate, !date.isEmpty {
                        statLine(
                            icon: "calendar",
                            tint: .paletteOrange,
                            title: "Released",
                            value: date
                        )
                    }
                case .tv(let show):
                    statLine(
                        icon: "rectangle.stack.fill",
                        tint: .paletteBlue,
                        title: "Seasons",
                        value: "\(show.numberOfSeasons)"
                    )
                    statLine(
                        icon: "play.rectangle.fill",
                        tint: .paletteOrange,
                        title: "Episodes",
                        value: "\(show.numberOfEpisodes)"
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func statLine(icon: String, tint: Color, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 22)

            Text(title)
                .font(.caption)
                .foregroundStyle(Color.cineTertiaryText)
                .frame(width: 64, alignment: .leading)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.cinePrimaryText)
        }
    }

    @ViewBuilder
    private func genresRow(_ genres: [Genre]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(genres) { genre in
                    Text(genre.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.cinePrimaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(genre.paletteColor.opacity(0.2), in: Capsule())
                        .overlay {
                            Capsule().stroke(genre.paletteColor.opacity(0.55), lineWidth: 1)
                        }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private func crewStrip(_ credits: Credits) -> some View {
        let directors = credits.directors.map(\.name)
        let writers = Array(Set(credits.writers.map(\.name))).sorted()
        if !directors.isEmpty || !writers.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                if !directors.isEmpty {
                    crewRow(label: "Directed by", names: directors)
                }
                if !writers.isEmpty {
                    crewRow(label: "Written by", names: writers)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func crewRow(label: String, names: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(Color.cineTertiaryText)
            Text(names.joined(separator: ", "))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.cinePrimaryText)
        }
    }

    @ViewBuilder
    private func castSection(_ cast: [CastMember]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Cast")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.cinePrimaryText)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(Array(cast.prefix(14))) { member in
                        VStack(alignment: .center, spacing: 8) {
                            CastAvatar(
                                path: member.profilePath,
                                imagePipeline: dependencies.imagePipeline
                            )

                            Text(member.name)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.cinePrimaryText)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .top)

                            Text(member.character)
                                .font(.caption2)
                                .foregroundStyle(Color.cineTertiaryText)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .top)
                        }
                        .frame(width: 88, alignment: .top)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    @ViewBuilder
    private func factsSection(_ details: MediaDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.cinePrimaryText)

            switch details {
            case .movie(let movie):
                factRow("Status", movie.status ?? "—")
                factRow("Budget", formatCurrency(movie.budget))
                factRow("Revenue", formatCurrency(movie.revenue))
                if let language = movie.originalLanguage {
                    factRow("Language", language.uppercased())
                }
            case .tv(let show):
                factRow("Status", show.status ?? "—")
                if let date = show.firstAirDate {
                    factRow("First air date", date)
                }
                if let language = show.originalLanguage {
                    factRow("Language", language.uppercased())
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func factRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.cineTertiaryText)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.cinePrimaryText)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
        }
    }

    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.cinePrimaryText)
            content()
        }
        .padding(.horizontal, 20)
    }

    private func formatRuntime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours == 0 { return "\(mins)m" }
        if mins == 0 { return "\(hours)h" }
        return "\(hours)h \(mins)m"
    }

    private func formattedCount(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatCurrency(_ value: Int) -> String {
        guard value > 0 else { return "—" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
