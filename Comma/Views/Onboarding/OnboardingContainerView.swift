//
//  OnboardingContainerView.swift
//  Comma
//
//  Container view managing the onboarding flow pages.
//

import SwiftUI

struct OnboardingContainerView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            HookView(onContinue: { currentPage = 1 })
                .tag(0)

            HowItWorksView(onContinue: { currentPage = 2 })
                .tag(1)

            PermissionsView(onContinue: { currentPage = 3 })
                .tag(2)

            AppSelectionView()
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: currentPage)
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingContainerView()
        .environment(AppState())
        .environment(AuthorizationManager())
}
