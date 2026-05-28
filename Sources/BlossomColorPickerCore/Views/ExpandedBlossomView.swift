import SwiftUI

public struct ExpandedBlossomView: View {
    @Bindable var model: BlossomColorPickerModel
    let layout: PetalLayout
    let supportsOpacity: Bool

    @Environment(\.blossomStyle) private var style

    public init(model: BlossomColorPickerModel, layout: PetalLayout, supportsOpacity: Bool = false) {
        self.model = model
        self.layout = layout
        self.supportsOpacity = supportsOpacity
    }

    public var body: some View {
        let controlRadius = Self.controlRadius(layout: layout, style: style)
        let totalSize = Self.totalSize(layout: layout, style: style)
        let center = CGPoint(x: totalSize / 2, y: totalSize / 2)

        foregroundContent(
            controlRadius: controlRadius,
            totalSize: totalSize,
            center: center,
        )
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if let (index, ring) = layout.petalIndex(at: value.location, center: center, petalSize: style.petalSize) {
                        if model.hoveredPetalIndex != index || model.hoveredRing != ring {
                            model.hoveredPetalIndex = index
                            model.hoveredRing = ring
                        }
                    } else {
                        model.hoveredPetalIndex = nil
                        model.hoveredRing = nil
                    }
                }
                .onEnded { value in
                    // Check if tap is on center circle
                    let dx = value.location.x - center.x
                    let dy = value.location.y - center.y
                    let distance = sqrt(dx * dx + dy * dy)

                    print("[Gesture] onEnded: location=\(value.location), center=\(center), distance=\(distance)")

                    if distance <= style.centerCircleSize / 2 {
                        print("[Gesture] selecting center color")
                        model.selectCenterColor(layout: layout)
                    } else if let (index, ring) = layout.petalIndex(at: value.location, center: center, petalSize: style.petalSize) {
                        // Tap on petal - check if it matches current selection
                        print("[Gesture] tap on petal: index=\(index), ring=\(ring)")
                        let tappedColor = layout.color(for: index, ring: ring)
                        if colorsMatch(tappedColor, model.selectedColor) {
                            print("[Gesture] petal color matches selected - collapsing")
                            model.confirmSelection()
                        } else {
                            print("[Gesture] selecting petal color")
                            model.selectPetal(index: index, ring: ring, layout: layout)
                        }
                    } else if isInsideArcControl(value.location, center: center, radius: controlRadius) {
                        print("[Gesture] tap on arc slider")
                    } else {
                        print("[Gesture] tap empty picker area - confirming")
                        model.confirmSelection()
                    }

                    model.hoveredPetalIndex = nil
                    model.hoveredRing = nil
                },
        )
        .onContinuousHover { phase in
            let center = CGPoint(x: totalSize / 2, y: totalSize / 2)
            switch phase {
            case let .active(location):
                if let (index, ring) = layout.petalIndex(at: location, center: center, petalSize: style.petalSize) {
                    model.hoveredPetalIndex = index
                    model.hoveredRing = ring
                } else {
                    model.hoveredPetalIndex = nil
                    model.hoveredRing = nil
                }
            case .ended:
                model.hoveredPetalIndex = nil
                model.hoveredRing = nil
            }
        }
    }

    @ViewBuilder
    private func foregroundContent(
        controlRadius: CGFloat,
        totalSize: CGFloat,
        center: CGPoint
    ) -> some View {
        ZStack {
            ColorPreviewArcView(
                color: supportsOpacity ? model.previewColor : model.selectedColor,
                radius: controlRadius,
                startAngle: previewArcAngles.start,
                endAngle: previewArcAngles.end,
                isExpanded: model.isExpanded,
            )

            // Blossom petals
            BlossomPetalsView(
                model: model,
                layout: layout,
                center: center,
            )
            .frame(width: totalSize, height: totalSize)

            // Center circle is a normal color option from the palette.
            // Appears first on expand, disappears last on collapse
            CenterCircleView(
                centerColor: layout.centerColor,
                showsCheckerboard: false,
                isExpanded: model.isExpanded,
                expandDelay: 0,
                collapseDelay: Double(layout.totalPetalCount) * BlossomConstants.petalAnimationDelay,
            )

            if supportsOpacity {
                ArcSliderView(model: model, radius: controlRadius, kind: .opacity)
            }

            ArcSliderView(model: model, radius: controlRadius, kind: .lightness)
        }
        .frame(width: totalSize, height: totalSize)
    }

    private func isInsideArcControl(_ point: CGPoint, center: CGPoint, radius: CGFloat) -> Bool {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        let trackWidth = style.sliderWidth + BlossomConstants.arcThumbSizeOffset + 8
        guard abs(distance - radius) <= trackWidth / 2 else { return false }

        let degrees = atan2(dy, dx) * 180 / .pi
        let normalizedDegrees = degrees < 0 ? degrees + 360 : degrees
        let isLightnessArc = degrees >= BlossomConstants.arcStartAngle - 10
            && degrees <= BlossomConstants.arcEndAngle + 10
        let previewAngles = previewArcAngles
        let isPreviewArc = if supportsOpacity {
            degrees >= previewAngles.start - 10
                && degrees <= previewAngles.end + 10
        } else {
            normalizedDegrees >= previewAngles.start - 10
                && normalizedDegrees <= previewAngles.end + 10
        }
        let isOpacityArc = supportsOpacity
            && normalizedDegrees >= BlossomConstants.opacityArcStartAngle - 10
            && normalizedDegrees <= BlossomConstants.opacityArcEndAngle + 10
        return isLightnessArc || isPreviewArc || isOpacityArc
    }

    private var previewArcAngles: (start: Double, end: Double) {
        supportsOpacity
            ? (BlossomConstants.previewArcStartAngle, BlossomConstants.previewArcEndAngle)
            : (BlossomConstants.opacityArcStartAngle, BlossomConstants.opacityArcEndAngle)
    }

    /// Calculate the total size needed for the expanded view
    public static func totalSize(layout: PetalLayout, style: BlossomStyle = .default) -> CGFloat {
        let radius = controlRadius(layout: layout, style: style)
        let controlDiameter = style.sliderWidth + BlossomConstants.arcThumbSizeOffset
        return radius * 2 + controlDiameter + BlossomConstants.viewPadding
    }

    private static func controlRadius(layout: PetalLayout, style: BlossomStyle) -> CGFloat {
        layout.outerRadius + style.petalSize / 2 + BlossomConstants.controlArcInset
    }
}

#if BLOSSOM_ENABLE_PREVIEWS
#Preview {
    @Previewable @State var model = BlossomColorPickerModel(initialColor: .green)

    ExpandedBlossomView(
        model: model,
        layout: PetalLayout(),
    )
    .onAppear {
        model.expand()
    }
    .padding(40)
}
#endif
