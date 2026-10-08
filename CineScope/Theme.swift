import SwiftUI

enum CineTheme {
    static let cardCornerRadius: CGFloat = 16
    static let gridSpacing: CGFloat = 12
}

extension Color {
    static let paletteBackground = Color("PaletteBackground")
    static let palettePrimary = Color("PalettePrimary")
    static let paletteSurface = Color("PaletteSurface")

    static let paletteBlue = Color("PaletteBlue")
    static let paletteGreen = Color("PaletteGreen")
    static let paletteYellow = Color("PaletteYellow")
    static let paletteOrange = Color("PaletteOrange")
    static let palettePink = Color("PalettePink")
    static let paletteRoyalBlue = Color("PaletteRoyalBlue")
    static let paletteMagenta = Color("PaletteMagenta")
    static let paletteTeal = Color("PaletteTeal")

    static let paletteGradientPlum = Color("PaletteGradientPlum")
    static let paletteGradientPeach = Color("PaletteGradientPeach")
    static let paletteGradientCharcoal = Color("PaletteGradientCharcoal")
    static let paletteGradientOlive = Color("PaletteGradientOlive")
}

extension Color {
    static let cineBackground = Color.paletteBackground
    static let cinePrimary = Color.palettePrimary
    static let cineAccent = Color.palettePrimary
    static let cineFavorite = Color.palettePink
    static let cineCard = Color.paletteSurface.opacity(0.92)
    static let cinePrimaryText = Color.white
    static let cineSecondaryText = Color.white.opacity(0.88)
    static let cineTertiaryText = Color.white.opacity(0.70)
    static let cineSuccess = Color.paletteGreen
    static let cineWarning = Color.paletteYellow
    static let cineInfo = Color.paletteBlue
}

enum CineGradient {
    static var primaryBlue: LinearGradient {
        LinearGradient(
            colors: [.palettePrimary, .paletteBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var sunset: LinearGradient {
        LinearGradient(
            colors: [.paletteGradientPlum, .paletteGradientPeach],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var muted: LinearGradient {
        LinearGradient(
            colors: [.paletteGradientCharcoal, .paletteGradientOlive],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var magentaPink: LinearGradient {
        LinearGradient(
            colors: [.paletteMagenta, .palettePink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var backgroundWash: LinearGradient {
        LinearGradient(
            colors: [
                Color.palettePrimary.opacity(0.55),
                Color.paletteBlue.opacity(0.28),
                Color.paletteBackground,
                Color.paletteMagenta.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var softGlow: RadialGradient {
        RadialGradient(
            colors: [
                Color.palettePrimary.opacity(0.45),
                Color.paletteBlue.opacity(0.18),
                .clear
            ],
            center: .topTrailing,
            startRadius: 20,
            endRadius: 420
        )
    }

    static var warmGlow: RadialGradient {
        RadialGradient(
            colors: [
                Color.paletteGradientPeach.opacity(0.22),
                Color.palettePink.opacity(0.10),
                .clear
            ],
            center: .bottomLeading,
            startRadius: 10,
            endRadius: 360
        )
    }
}
