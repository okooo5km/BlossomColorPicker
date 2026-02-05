# BlossomColorPicker

A beautiful flower-shaped color picker for SwiftUI. Fully written by AI, tested by myself.

![Preview](Previews/preview.gif)

## Features

- Petal-based color selection with smooth animations
- Works on iOS and macOS
- Simple SwiftUI integration
- Customizable color palette via JSON
- Brightness slider built-in

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

    var body: some View {
        BlossomColorPicker(selection: $color)
            .frame(width: 32, height: 32)
    }
}
```

### Callback Style

```swift
BlossomColorPicker(
    initialColor: .orange,
    onColorChange: { color in
        print("Color changed: \(color)")
    },
    onDismiss: { finalColor in
        print("Picker closed with: \(finalColor)")
    }
)
```

## How It Works

1. Tap the color swatch to open the picker
2. Drag or tap on petals to select a color
3. Use the side slider to adjust brightness
4. Tap the same color or outside to close

## License

MIT License - see [LICENSE](LICENSE) for details.

---

Made with care by [@Lakr233](https://github.com/Lakr233), idea from [@lichinlin](https://x.com/lichinlin/status/2019084548072689980).
