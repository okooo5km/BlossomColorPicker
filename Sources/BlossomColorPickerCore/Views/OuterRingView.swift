import SwiftUI

struct ColorPreviewArcView: View {
    let color: Color
    let radius: CGFloat
    let startAngle: Double
    let endAngle: Double
    let isExpanded: Bool

    @Environment(\.blossomStyle) private var style

    var body: some View {
        ZStack {
            ArcShape(
                startAngle: .degrees(startAngle),
                endAngle: .degrees(endAngle)
            )
            .stroke(
                .primary.opacity(0.08),
                style: StrokeStyle(lineWidth: style.sliderWidth + 2, lineCap: .round)
            )

            ArcShape(
                startAngle: .degrees(startAngle),
                endAngle: .degrees(endAngle)
            )
            .stroke(
                color.opacity(max(colorOpacity, 0.55)),
                style: StrokeStyle(lineWidth: style.sliderWidth, lineCap: .round)
            )
        }
        .frame(width: radius * 2, height: radius * 2)
        .scaleEffect(isExpanded ? 1.0 : 0.0)
        .opacity(isExpanded ? 1.0 : 0.0)
        .animation(.blossom(delay: BlossomConstants.arcSliderAnimationDelay), value: isExpanded)
        .animation(.blossom, value: color)
    }

    private var colorOpacity: Double {
        extractHSBA(from: color).alpha
    }
}

#if BLOSSOM_ENABLE_PREVIEWS
#Preview {
    ColorPreviewArcView(
        color: .green,
        radius: 100,
        startAngle: BlossomConstants.previewArcStartAngle,
        endAngle: BlossomConstants.previewArcEndAngle,
        isExpanded: true,
    )
    .padding(40)
}
#endif
