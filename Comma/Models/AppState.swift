//
//  AppState.swift
//  Comma
//
//  Observable app-wide state management.
//

import SwiftUI

@MainActor
@Observable
final class AppState {
    /// Whether onboarding has been completed (stored property for @Observable tracking)
    var hasCompletedOnboarding: Bool {
        didSet {
            // Sync to persistent storage
            AppGroupManager.shared.hasCompletedOnboarding = hasCompletedOnboarding
        }
    }

    /// Whether the breathing room should be displayed
    var shouldShowBreathingRoom: Bool = false

    /// URL that triggered the app open (if any)
    var pendingDeepLink: URL?

    init() {
        // Load initial value from persistent storage
        self.hasCompletedOnboarding = AppGroupManager.shared.hasCompletedOnboarding
    }

    /// Handles incoming URL scheme
    func handleIncomingURL(_ url: URL) {
        // URL scheme: comma://breathe
        guard url.scheme == SharedConstants.urlScheme else { return }

        if url.host == "breathe" {
            shouldShowBreathingRoom = true
        }

        pendingDeepLink = url
    }

    /// Clears the breathing room state after completion
    func breathingCompleted() {
        shouldShowBreathingRoom = false
        pendingDeepLink = nil
    }
}
