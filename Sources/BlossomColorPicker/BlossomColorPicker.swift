import BlossomColorPickerCore
import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
#endif

// Type alias for platform-specific presenter
#if canImport(UIKit)
    typealias PickerPresenter = PickerViewPresenter
#elseif canImport(AppKit)
    typealias PickerPresenter = PickerWindowPresenter
#endif

public struct BlossomColorPicker: View {
    @Binding private var selection: Color
    private let opacity: Binding<Double>?
    @StateObject private var model: BlossomColorPickerModel
    @State private var presenter = PickerPresenter()
    @State private var isCooldown = false
    @State private var previousExpansion = false

    private let layout: PetalLayout
    private let supportsOpacity: Bool
    private let onColorChange: ((Color) -> Void)?
    private let onOpacityChange: ((Double) -> Void)?
    private let onDismiss: ((Color) -> Void)?

    private var boundOpacity: Double? {
        opacity?.wrappedValue
    }

    public init(
        selection: Binding<Color>,
        opacity: Binding<Double>? = nil,
        supportsOpacity: Bool = false,
        layout: PetalLayout = PetalLayout(),
        onColorChange: ((Color) -> Void)? = nil,
        onOpacityChange: ((Double) -> Void)? = nil,
        onDismiss: ((Color) -> Void)? = nil,
    ) {
        _selection = selection
        self.opacity = opacity
        _model = StateObject(
            wrappedValue: BlossomColorPickerModel(
                initialColor: selection.wrappedValue,
                opacity: opacity?.wrappedValue
            ))
        self.layout = layout
        self.supportsOpacity = supportsOpacity && opacity != nil
        self.onColorChange = onColorChange
        self.onOpacityChange = onOpacityChange
        self.onDismiss = onDismiss
    }

    public init(
        initialColor: Color = .blue,
        initialOpacity: Double = 1.0,
        supportsOpacity: Bool = false,
        layout: PetalLayout = PetalLayout(),
        onColorChange: ((Color) -> Void)? = nil,
        onOpacityChange: ((Double) -> Void)? = nil,
        onDismiss: ((Color) -> Void)? = nil,
    ) {
        _selection = .constant(initialColor)
        opacity = nil
        _model = StateObject(wrappedValue: BlossomColorPickerModel(initialColor: initialColor, opacity: initialOpacity))
        self.layout = layout
        self.supportsOpacity = supportsOpacity
        self.onColorChange = onColorChange
        self.onOpacityChange = onOpacityChange
        self.onDismiss = onDismiss
    }

    public var body: some View {
        // Collapsed swatch only - respects frame modifier
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                if supportsOpacity {
                    BlossomCheckerboardView(tileSize: max(size / 4, 4))
                }
                Circle()
                    .fill(supportsOpacity ? model.previewColor : model.selectedColor)
            }
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        .primary.opacity(BlossomConstants.collapsedSwatchBorderOpacity),
                        lineWidth: BlossomConstants.borderWidth,
                    ),
            )
            .frame(width: size, height: size)
            .contentShape(Circle())
            .onTapGesture {
                // Prevent rapid re-opening
                guard !isCooldown else {
                    print("[BlossomColorPicker] tap ignored - cooldown active")
                    return
                }

                print("[BlossomColorPicker] tap gesture, model.isExpanded: \(model.isExpanded)")

                // Start cooldown
                isCooldown = true
                Task {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    isCooldown = false
                }

                // Get screen position of swatch center
                let frame = geometry.frame(in: .global)
                let screenPoint = convertToScreenCoordinates(frame: frame)
                print("[BlossomColorPicker] calling presenter.show()")
                presenter.show(at: screenPoint, model: model, layout: layout, supportsOpacity: supportsOpacity)
            }
            .accessibilityLabel("Color picker")
            .accessibilityHint("Tap to expand color picker")
            .accessibilityAddTraits(.isButton)
        }
        .aspectRatio(1, contentMode: .fit)
        .onChange(of: model.selectedColor) { newValue in
            selection = newValue
            onColorChange?(newValue)
        }
        .onChange(of: model.opacity) { newValue in
            opacity?.wrappedValue = newValue
            onOpacityChange?(newValue)
        }
        .onChange(of: selection) { newValue in
            if model.selectedColor != newValue {
                model.selectedColor = newValue
            }
        }
        .onChange(of: boundOpacity) { newValue in
            guard let newValue, abs(model.opacity - newValue) > 0.001 else { return }
            model.updateOpacity(newValue)
        }
        .onChange(of: model.isExpanded) { isExpanded in
            print("[BlossomColorPicker] onChange isExpanded: \(previousExpansion) -> \(isExpanded)")
            defer {
                previousExpansion = isExpanded
            }
            if previousExpansion, !isExpanded {
                print("[BlossomColorPicker] calling presenter.dismiss()")
                presenter.dismiss()
                onDismiss?(model.selectedColor)
            }
        }
    }

    /// Convert SwiftUI global coordinates to screen coordinates
    private func convertToScreenCoordinates(frame: CGRect) -> CGPoint {
        #if canImport(UIKit)
            // UIKit: SwiftUI .global coordinates are in screen coordinates (top-left origin)
            return CGPoint(x: frame.midX, y: frame.midY)
        #else
            // AppKit: SwiftUI .global coordinates are relative to the window
            // We need to convert to NSScreen coordinates (bottom-up)
            guard let window = NSApp.keyWindow else {
                return CGPoint(x: frame.midX, y: frame.midY)
            }

            let windowFrame = window.frame

            // SwiftUI Y is top-down within the window
            // NSScreen Y is bottom-up from screen origin
            // Window's frame.origin is already in screen coordinates (bottom-left of window)
            let centerX = windowFrame.origin.x + frame.midX
            let centerY = windowFrame.origin.y + windowFrame.height - frame.midY

            return CGPoint(x: centerX, y: centerY)
        #endif
    }
}

#if BLOSSOM_ENABLE_PREVIEWS
    #Preview("Binding-based") {
        @Previewable @State var color = Color.blue

        VStack(spacing: 40) {
            BlossomColorPicker(selection: $color)
                .frame(width: 32, height: 32)

            Rectangle()
                .fill(color)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(60)
    }

    #Preview("Callback-based") {
        BlossomColorPicker(
            initialColor: .orange,
            onColorChange: { color in
                print("Color changed: \(color)")
            },
            onDismiss: { finalColor in
                print("Dismissed with: \(finalColor)")
            },
        )
        .frame(width: 32, height: 32)
        .padding(60)
    }
#endif
