//
//  ShieldActionExtension.swift
//  ShieldAction
//
//  Created by Albert Chehebar on 12/8/25.
//

import ManagedSettings
import UserNotifications

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {

    // MARK: - Application Shield Actions

    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handleAction(action, completionHandler: completionHandler)
    }

    // MARK: - Web Domain Shield Actions

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handleAction(action, completionHandler: completionHandler)
    }

    // MARK: - Category Shield Actions

    override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handleAction(action, completionHandler: completionHandler)
    }

    // MARK: - Shared Action Handler

    private func handleAction(
        _ action: ShieldAction,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            // Log the event
            logEvent(.attemptedEntry)

            // Schedule a notification to open Comma app
            scheduleBreathingNotification()

            // Close the blocked app
            completionHandler(.close)

        case .secondaryButtonPressed:
            // Secondary button removed, but handle gracefully if called
            completionHandler(.close)

        @unknown default:
            completionHandler(.close)
        }
    }

    // MARK: - Notification Scheduling

    private func scheduleBreathingNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to breathe"
        content.body = "Tap to start your breathing exercise"
        content.sound = .default
        content.userInfo = ["action": "breathe"]

        // Trigger immediately (1 second delay required by iOS)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "comma-breathe-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("ShieldAction: Failed to schedule notification - \(error)")
            }
        }
    }

    // MARK: - Event Logging

    private func logEvent(_ outcome: PauseOutcome) {
        Task {
            do {
                let storage = try PauseEventStorage()
                try await storage.logEvent(outcome)
            } catch {
                // Log silently - don't block the action
                print("ShieldAction: Failed to log event - \(error)")
            }
        }
    }
}
