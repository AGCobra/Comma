//
//  PermissionsView.swift
//  Comma
//
//  Third onboarding screen - requests FamilyControls and notification authorization.
//

import SwiftUI
import FamilyControls
import UserNotifications
import UIKit

struct PermissionsView: View {
    @Environment(AuthorizationManager.self) private var authManager
    let onContinue: () -> Void

    @State private var isRequesting = false
    @State private var showDeniedAlert = false
    @State private var deniedAlertMessage = ""

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 16) {
                Text("Permissions Required")
                    .font(.largeTitle.bold())

                Text("Comma needs Screen Time access to create mindful pauses, and notifications to guide you through breathing exercises.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("Your data stays on your device.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Button(action: requestPermissions) {
                HStack {
                    if isRequesting {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Allow Permissions")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(isRequesting)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
        .alert("Permission Denied", isPresented: $showDeniedAlert) {
            Button("Try Again", action: requestPermissions)
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(deniedAlertMessage)
        }
    }

    private func requestPermissions() {
        isRequesting = true

        Task {
            // Request Screen Time authorization
            await authManager.requestAuthorization()

            // Request notification authorization
            let notificationCenter = UNUserNotificationCenter.current()
            let notificationsGranted = (try? await notificationCenter.requestAuthorization(options: [.alert, .sound])) ?? false

            // Check current notification settings (in case already granted)
            let notificationSettings = await notificationCenter.notificationSettings()
            let notificationsEnabled = notificationSettings.authorizationStatus == .authorized

            await MainActor.run {
                isRequesting = false

                let screenTimeGranted = authManager.isAuthorized
                let notificationsOk = notificationsGranted || notificationsEnabled

                if screenTimeGranted && notificationsOk {
                    onContinue()
                } else {
                    // Build specific error message
                    var missingPermissions: [String] = []
                    if !screenTimeGranted {
                        missingPermissions.append("Screen Time")
                    }
                    if !notificationsOk {
                        missingPermissions.append("Notifications")
                    }
                    deniedAlertMessage = "\(missingPermissions.joined(separator: " and ")) access is required for Comma to work. Please allow access to continue."
                    showDeniedAlert = true
                }
            }
        }
    }
}

#Preview {
    PermissionsView(onContinue: {})
        .environment(AuthorizationManager())
}
