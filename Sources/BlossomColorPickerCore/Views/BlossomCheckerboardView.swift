import SwiftUI

public struct BlossomCheckerboardView: View {
    public let tileSize: CGFloat

    public init(tileSize: CGFloat = 8) {
        self.tileSize = tileSize
    }

    public var body: some View {
        Canvas { context, size in
            let columns = Int(ceil(size.width / tileSize))
            let rows = Int(ceil(size.height / tileSize))

            for row in 0..<rows {
                for column in 0..<columns {
                    let isDarkTile = (row + column).isMultiple(of: 2)
                    let rect = CGRect(
                        x: CGFloat(column) * tileSize,
                        y: CGFloat(row) * tileSize,
                        width: tileSize,
                        height: tileSize,
                    )
                    context.fill(
                        Path(rect),
                        with: .color(isDarkTile ? Color.primary.opacity(0.09) : Color.primary.opacity(0.025))
                    )
                }
            }
        }
        .drawingGroup()
    }
}
