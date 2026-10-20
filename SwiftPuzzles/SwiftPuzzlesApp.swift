//
//  SwiftPuzzlesApp.swift
//  SwiftPuzzles
//
//  Created by Александр Тихонов on 20.10.2026.
//

import SwiftUI

@main
struct SwiftPuzzlesApp: App {
    private let catalog = ContentLoader.loadOrCrash()

    var body: some Scene {
        WindowGroup {
            HomeView(catalog: catalog)
        }
    }
}
