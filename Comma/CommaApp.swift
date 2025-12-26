//
//  CommaApp.swift
//  Comma
//
//  Created by Albert Chehebar on 12/8/25.
//

import SwiftUI
import FamilyControls
import UserNotifications

@main
struct CommaApp: App {
    @State private var appState = AppState()
    @State private var authManager = AuthorizationManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(authManager)
                .onOpenURL { url in
                    appState.handleIncomingURL(url)
                }
                .onAppear {
                    // Share appState with AppDelegate for notification handling
                    appDelegate.appState = appState
                }
        }
    }
}

// MARK: - AppDelegate for Notification Handling

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var appState: AppState?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Handle notification tap when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        if userInfo["action"] as? String == "breathe" {
            // Show breathing room immediately when notification arrives
            DispatchQueue.main.async {
                self.appState?.shouldShowBreathingRoom = true
            }
            // Don't show the notification banner since we're handling it
            completionHandler([])
        } else {
            completionHandler([.banner, .sound])
        }
    }

    // Handle notification tap when app is in background or closed
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if userInfo["action"] as? String == "breathe" {
            DispatchQueue.main.async {
                self.appState?.shouldShowBreathingRoom = true
            }
        }
        completionHandler()
    }
}
