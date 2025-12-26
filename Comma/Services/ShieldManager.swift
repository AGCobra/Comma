//
//  ShieldManager.swift
//  Comma
//
//  Manages shield application and removal via ManagedSettingsStore.
//

import ManagedSettings
import FamilyControls
import DeviceActivity
import SwiftUI

@MainActor
@Observable
final class ShieldManager {
    static let shared = ShieldManager()

    private let store = ManagedSettingsStore()
    private let activityCenter = DeviceActivityCenter()

    var selectedApps: FamilyActivitySelection = FamilyActivitySelection()

    private init() {
        loadSavedSelection()
    }

    // MARK: - Selection Persistence

    /// Loads the saved app selection from UserDefaults
    private func loadSavedSelection() {
        guard let data = AppGroupManager.shared.userDefaults.data(
            forKey: SharedConstants.UserDefaultsKeys.selectedApps
        ) else { return }

        do {
            let decoded = try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
            selectedApps = decoded
        } catch {
            print("Failed to decode saved selection: \(error)")
        }
    }

    /// Saves the app selection and applies shields
    func saveSelection(_ selection: FamilyActivitySelection) {
        selectedApps = selection

        do {
            let encoded = try JSONEncoder().encode(selection)
            AppGroupManager.shared.userDefaults.set(
                encoded,
                forKey: SharedConstants.UserDefaultsKeys.selectedApps
            )
        } catch {
            print("Failed to encode selection: \(error)")
        }

        applyShields()
    }

    // MARK: - Shield Management

    /// Applies shields to the selected apps
    func applyShields() {
        store.shield.applications = selectedApps.applicationTokens
        store.shield.applicationCategories = .specific(selectedApps.categoryTokens)
    }

    /// Removes all shields
    func removeShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    /// Temporarily unlocks shields for the configured duration
    func temporarilyUnlock() {
        // Remove shields immediately
        removeShields()

        // Set unlock expiration in shared storage (using user-configured duration)
        let unlockDuration = AppGroupManager.shared.unlockDurationSeconds
        AppGroupManager.shared.setUnlocked(for: unlockDuration)

        // Schedule re-shielding via DeviceActivityMonitor
        scheduleReshield()
    }

    /// Schedules the shields to be re-applied after the unlock duration
    private func scheduleReshield() {
        let activityName = DeviceActivityName(SharedConstants.ActivityNames.reshieldActivity)

        // Stop any existing monitoring for this activity
        activityCenter.stopMonitoring([activityName])

        // Calculate the end time (now + unlock duration)
        let unlockDuration = AppGroupManager.shared.unlockDurationSeconds
        let endDate = Date().addingTimeInterval(unlockDuration)
        let endComponents = Calendar.current.dateComponents(
            [.hour, .minute, .second],
            from: endDate
        )

        // Create a schedule that ends at the unlock expiration time
        // We use today's date for the start, and the end time for when to trigger
        let now = Date()
        let startComponents = Calendar.current.dateComponents(
            [.hour, .minute, .second],
            from: now
        )

        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )

        do {
            try activityCenter.startMonitoring(activityName, during: schedule)
        } catch {
            print("Failed to schedule re-shielding: \(error)")
            // As a fallback, immediately re-apply shields after delay
            Task {
                try? await Task.sleep(for: .seconds(unlockDuration))
                await MainActor.run {
                    applyShields()
                }
            }
        }
    }

    /// Returns true if there are apps selected for shielding
    var hasSelectedApps: Bool {
        !selectedApps.applicationTokens.isEmpty || !selectedApps.categoryTokens.isEmpty
    }
}
