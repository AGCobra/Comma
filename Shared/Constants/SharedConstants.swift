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
        static let unlockDurationMinutes = "unlockDurationMinutes"
        static let breathingDurationSeconds = "breathingDurationSeconds"
    }

    enum ActivityNames {
        static let reshieldActivity = "com.Albert.comma.reshield"
    }

    /// Default duration the app remains unlocked after breathing (15 minutes)
    static let defaultUnlockDurationMinutes: Int = 15

    /// Default duration of the breathing exercise (10 seconds)
    static let defaultBreathingDurationSeconds: Int = 10

    /// Available unlock duration options (in minutes)
    static let unlockDurationOptions: [Int] = [5, 10, 15, 30, 60]

    /// Available breathing duration options (in seconds)
    static let breathingDurationOptions: [Int] = [10, 15, 20, 30]
}
