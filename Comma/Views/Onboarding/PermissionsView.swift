//
//  PermissionsView.swift
//  Comma
//
//  Third onboarding screen - requests FamilyControls authorization.
//

import SwiftUI
import FamilyControls

struct PermissionsView: View {
    @Environment(AuthorizationManager.self) private var authManager
    let onContinue: () -> Void

    @State private var isRequesting = false
    @State private var showDeniedAlert = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 16) {
                Text("Permission Required")
                    .font(.largeTitle.bold())

                Text("Comma needs Screen Time access to create mindful pauses before opening selected apps.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("Your data stays on your device.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Button(action: requestPermission) {
                HStack {
                    if isRequesting {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Allow Screen Time Access")
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
            Button("Try Again", action: requestPermission)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Screen Time access is required for Comma to work. Please allow access to continue.")
        }
    }

    private func requestPermission() {
        isRequesting = true

        Task {
            await authManager.requestAuthorization()

            await MainActor.run {
                isRequesting = false

                if authManager.isAuthorized {
                    onContinue()
                } else {
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
