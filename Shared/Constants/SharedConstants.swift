//
//  SharedConstants.swift
//  Comma
//
//  Shared constants used across all targets.
//

import Foundation

enum SharedConstants {
    static let appGroupID = "group.com.Albert.comma"
    static let urlScheme = "comma"

    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedApps = "selectedApps"
        static let unlockExpirationDate = "unlockExpirationDate"
        static let lastBreathingCompletedDate = "lastBreathingCompletedDate"
    }

    enum ActivityNames {
        static let reshieldActivity = "com.Albert.comma.reshield"
    }

    /// Duration the app remains unlocked after breathing (15 minutes)
    static let unlockDurationSeconds: TimeInterval = 15 * 60

    /// Duration of the breathing exercise (10 seconds)
    static let breathingDurationSeconds: TimeInterval = 10
}
