import SwiftUI

struct CircularRatingView: View {
    let value: Double
    var maxValue: Double = 10
    var size: CGFloat = 64
    var lineWidth: CGFloat = 5

    private var progress: CGFloat {
        CGFloat(min(max(value / maxValue, 0), 1))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    CineGradient.primaryBlue,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 1) {
                Text(String(format: "%.1f", value))
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.cinePrimaryText)
                Text("TMDB")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(Color.cineTertiaryText)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Rating \(String(format: "%.1f", value)) out of 10")
    }
}
