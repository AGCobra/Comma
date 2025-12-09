//
//  ShieldActionExtension.swift
//  ShieldAction
//
//  Created by Albert Chehebar on 12/8/25.
//

import ManagedSettings
import UIKit

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

            // Try to open Comma app directly
            openCommaApp()

            // Close the blocked app
            completionHandler(.close)

        case .secondaryButtonPressed:
            // Secondary button removed, but handle gracefully if called
            completionHandler(.close)

        @unknown default:
            completionHandler(.close)
        }
    }

    // MARK: - Open Comma App

    private func openCommaApp() {
        guard let url = URL(string: "comma://breathe") else { return }

        // Use Objective-C runtime to access UIApplication.shared
        // This works around the extension limitation where UIApplication.shared is unavailable
        let sharedSelector = NSSelectorFromString("sharedApplication")
        guard let appClass = NSClassFromString("UIApplication") as? NSObject.Type,
              let sharedApp = appClass.perform(sharedSelector)?.takeUnretainedValue() as? NSObject else {
            return
        }

        // Call openURL: method
        let openSelector = NSSelectorFromString("openURL:")
        sharedApp.perform(openSelector, with: url)
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
