//
//  linkedinMEApp.swift
//  linkedinME
//
//  Created by John Demirci on 3/27/26.
//

import SwiftUI
import Supervision

struct AppEnvironment {
    let client: Client
    let clipboard: Clipboard

    init() {
        self.client = .init()
        self.clipboard = .init()
    }
}

@main
struct linkedinMEApp: App {
    private let container: FeatureContainer<AppEnvironment>

    init() {
        let environment = AppEnvironment()
        let _container = FeatureContainer(dependency: environment)

        self.container = _container
    }

    var body: some Scene {
        WindowGroup {
            TranslationView(feature: container.translationFeature())
        }
    }
}
