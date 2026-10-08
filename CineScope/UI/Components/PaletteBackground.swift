import SwiftUI
import CineScopeCore

struct PaletteBackground: View {
    var body: some View {
        ZStack {
            Color.cineBackground
            CineGradient.backgroundWash
            CineGradient.softGlow
            CineGradient.warmGlow
        }
        .ignoresSafeArea()
    }
}

extension View {
    func cineScreenBackground() -> some View {
        background(PaletteBackground())
    }
}

extension Genre {
    var paletteColor: Color {
        let colors: [Color] = [
            .paletteBlue,
            .paletteTeal,
            .paletteMagenta,
            .paletteOrange,
            .paletteGreen,
            .paletteRoyalBlue,
            .palettePink,
            .paletteYellow
        ]
        return colors[abs(id) % colors.count]
    }
}
