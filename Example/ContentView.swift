//
//  ContentView.swift
//  Example
//
//  Created by 秋星桥 on 2026/02/05.
//

import BlossomColorPicker
import SwiftUI

struct ContentView: View {
    @State private var selectedColor: Color = .init(hue: 214.0 / 360.0, saturation: 0.121, brightness: 0.973)

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            BlossomColorPicker(selection: $selectedColor)
                .frame(width: 32, height: 32)
            Text("Color Picker")
                .bold()
            Text("Click on the color to open picker")
            Spacer()
        }
        .padding()
        .frame(minWidth: 350)
    }
}

#Preview {
    ContentView()
}
