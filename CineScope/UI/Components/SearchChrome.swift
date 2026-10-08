import SwiftUI
import CineScopeCore

struct MediaKindPicker: View {
    @Binding var selection: MediaKind

    var body: some View {
        HStack(spacing: 8) {
            kindButton(title: "Movies", kind: .movie, systemImage: "film")
            kindButton(title: "Series", kind: .tv, systemImage: "play.tv")
        }
        .padding(4)
        .background {
            Capsule()
                .fill(Color.cineCard)
                .overlay { Capsule().fill(Color.white.opacity(0.08)) }
        }
        .overlay {
            Capsule().stroke(Color.palettePrimary.opacity(0.35), lineWidth: 1)
        }
        .accessibilityIdentifier("search.kind.picker")
    }

    private func kindButton(title: String, kind: MediaKind, systemImage: String) -> some View {
        let isSelected = selection == kind
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selection = kind
            }
        } label: {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : Color.cineSecondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    if isSelected {
                        Capsule().fill(CineGradient.primaryBlue)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
