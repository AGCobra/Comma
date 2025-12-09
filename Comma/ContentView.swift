//
//  ContentView.swift
//  Comma
//
//  Created by Albert Chehebar on 12/8/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthorizationManager.self) private var authManager

    var body: some View {
        Group {
            if appState.shouldShowBreathingRoom {
                BreathingRoomView()
            } else if !appState.hasCompletedOnboarding {
                OnboardingContainerView()
            } else {
                DashboardView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.shouldShowBreathingRoom)
        .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .environment(AuthorizationManager())
}
