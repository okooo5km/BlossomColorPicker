//
//  ExampleApp.swift
//  Example
//
//  Created by 秋星桥 on 2026/02/05.
//

import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
