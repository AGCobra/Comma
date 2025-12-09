//
//  AppGroupManager.swift
//  Comma
//
//  Manages shared data access via App Group container.
//

import Foundation

final class AppGroupManager: @unchecked Sendable {
    static let shared = AppGroupManager()

    let userDefaults: UserDefaults
    let containerURL: URL

    private init() {
        guard let defaults = UserDefaults(suiteName: SharedConstants.appGroupID) else {
            fatalError("Failed to access App Group UserDefaults for \(SharedConstants.appGroupID)")
        }
        self.userDefaults = defaults

        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: SharedConstants.appGroupID
        ) else {
            fatalError("Failed to access App Group container for \(SharedConstants.appGroupID)")
        }
        self.containerURL = url
    }

    // MARK: - Unlock State

    /// Returns true if the apps are currently unlocked (within the unlock window)
    var isUnlocked: Bool {
        guard let expiration = unlockExpirationDate else { return false }
        return Date() < expiration
    }

    /// The date when the current unlock expires
    var unlockExpirationDate: Date? {
        get {
            userDefaults.object(forKey: SharedConstants.UserDefaultsKeys.unlockExpirationDate) as? Date
        }
        set {
            userDefaults.set(newValue, forKey: SharedConstants.UserDefaultsKeys.unlockExpirationDate)
        }
    }

    /// Sets the unlock state for a specified duration
    func setUnlocked(for duration: TimeInterval) {
        unlockExpirationDate = Date().addingTimeInterval(duration)
    }

    /// Clears the unlock state, re-enabling shields
    func clearUnlock() {
        unlockExpirationDate = nil
    }

    // MARK: - Onboarding State

    var hasCompletedOnboarding: Bool {
        get {
            userDefaults.bool(forKey: SharedConstants.UserDefaultsKeys.hasCompletedOnboarding)
        }
        set {
            userDefaults.set(newValue, forKey: SharedConstants.UserDefaultsKeys.hasCompletedOnboarding)
        }
    }
}
