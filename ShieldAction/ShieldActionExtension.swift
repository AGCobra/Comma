//
//  ShieldActionExtension.swift
//  ShieldAction
//
//  Created by Albert Chehebar on 12/8/25.
//

import ManagedSettings

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
            // User wants to breathe - log attempted entry
            logEvent(.attemptedEntry)
            // Return .none to let the system handle it
            // User will need to manually open Comma app
            completionHandler(.none)

        case .secondaryButtonPressed:
            // User chose not to open the app - mindful close
            logEvent(.mindfulClose)
            completionHandler(.close)

        @unknown default:
            completionHandler(.close)
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
