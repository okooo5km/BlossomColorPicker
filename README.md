# BlossomColorPicker

A beautiful flower-shaped color picker for SwiftUI. Fully written by AI, tested by myself.

![Preview](Previews/preview.gif)

## Features

- Petal-based color selection with smooth animations
- Works on iOS and macOS
- Simple SwiftUI integration
- Customizable color palette via JSON
- Brightness slider built-in
- Optional opacity slider for alpha-capable workflows

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 6.0+

> **Note:** This picker is designed for pointer-based interaction. Not recommended on iOS or mobile devices without a pointer device (e.g., Apple Pencil, trackpad, or mouse).

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Lakr233/BlossomColorPicker", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → paste the URL.

## Usage

```swift
import BlossomColorPicker
import SwiftUI

struct ContentView: View {
    @State private var color: Color = .blue
    @State private var opacity: Double = 1

    var body: some View {
        BlossomColorPicker(
            selection: $color,
            opacity: $opacity,
            supportsOpacity: true
        )
            .frame(width: 32, height: 32)
    }
}
```

### Callback Style

```swift
BlossomColorPicker(
    initialColor: .orange,
    initialOpacity: 0.8,
    supportsOpacity: true,
    onColorChange: { color in
        print("Color changed: \(color)")
    },
    onOpacityChange: { opacity in
        print("Opacity changed: \(opacity)")
    },
    onDismiss: { finalColor in
        print("Picker closed with: \(finalColor)")
    }
)
```

## How It Works

1. Tap the color swatch to open the picker
2. Drag or tap on petals or the center dot to select a color
3. Use the side slider to adjust brightness
4. Enable `supportsOpacity` to show a mirrored opacity slider on the left
5. Tap empty space or the check button to confirm; tap the x button to cancel

## Release Notes

This project currently ships by tagging releases, starting from `1.0.0`.
There is no changelog or automated release workflow in the repository yet.

## License

MIT License - see [LICENSE](LICENSE) for details.

---

Made with care by [@Lakr233](https://github.com/Lakr233), idea from [@lichinlin](https://x.com/lichinlin/status/2019084548072689980).
