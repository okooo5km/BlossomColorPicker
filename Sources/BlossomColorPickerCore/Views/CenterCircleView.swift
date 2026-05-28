import SwiftUI

struct CenterCircleView: View {
    let centerColor: Color
    let showsCheckerboard: Bool
    let isExpanded: Bool
    let expandDelay: Double
    let collapseDelay: Double

    @Environment(\.blossomStyle) private var style

    var body: some View {
        ZStack {
            if showsCheckerboard {
                BlossomCheckerboardView(tileSize: 5)
            }

            Circle()
                .fill(centerColor)
        }
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.gray.opacity(BlossomConstants.centerBorderOpacity), lineWidth: BlossomConstants.borderWidth),
        )
        .frame(width: style.centerCircleSize, height: style.centerCircleSize)
        .scaleEffect(isExpanded ? 1.0 : 0.0)
        .opacity(isExpanded ? 1.0 : 0.0)
        .animation(.blossom(delay: isExpanded ? expandDelay : collapseDelay), value: isExpanded)
    }
}

#if BLOSSOM_ENABLE_PREVIEWS
#Preview {
    ZStack {
        Color.gray.opacity(0.3)
        CenterCircleView(
            centerColor: .white,
            showsCheckerboard: false,
            isExpanded: true,
            expandDelay: 0,
            collapseDelay: 0.3,
        )
    }
    .frame(width: 200, height: 200)
}
#endif
