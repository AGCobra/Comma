//
//  CommaApp.swift
//  Comma
//
//  Created by Albert Chehebar on 12/8/25.
//

import SwiftUI
import FamilyControls

@main
struct CommaApp: App {
    @State private var appState = AppState()
    @State private var authManager = AuthorizationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(authManager)
                .onOpenURL { url in
                    appState.handleIncomingURL(url)
                }
        }
    }
}
