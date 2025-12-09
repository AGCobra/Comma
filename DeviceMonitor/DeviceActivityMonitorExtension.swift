//
//  DeviceActivityMonitorExtension.swift
//  DeviceMonitor
//
//  Created by Albert Chehebar on 12/8/25.
//

import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    private let store = ManagedSettingsStore()

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // Interval started - no action needed
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        // Check if this is our re-shielding activity
        if activity.rawValue == SharedConstants.ActivityNames.reshieldActivity {
            reapplyShields()
        }
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)
        // Can be used for usage-based triggers in the future
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        // Warning before interval starts - no action needed
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        // Could notify user that unlock is about to expire
    }

    override func eventWillReachThresholdWarning(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        // Warning before threshold is reached
    }

    // MARK: - Re-shielding Logic

    private func reapplyShields() {
        // Clear the unlock state
        AppGroupManager.shared.clearUnlock()

        // Load saved selection from App Group UserDefaults
        guard let data = AppGroupManager.shared.userDefaults.data(
            forKey: SharedConstants.UserDefaultsKeys.selectedApps
        ) else {
            print("DeviceMonitor: No saved selection found")
            return
        }

        do {
            let selection = try JSONDecoder().decode(FamilyActivitySelection.self, from: data)

            // Re-apply shields
            store.shield.applications = selection.applicationTokens
            store.shield.applicationCategories = .specific(selection.categoryTokens)

            print("DeviceMonitor: Shields re-applied successfully")
        } catch {
            print("DeviceMonitor: Failed to decode selection - \(error)")
        }
    }
}
