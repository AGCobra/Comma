//
//  AppSelectionView.swift
//  Comma
//
//  Fourth onboarding screen - app selection via FamilyActivityPicker.
//

import SwiftUI
import FamilyControls

struct AppSelectionView: View {
    @Environment(AppState.self) private var appState
    @State private var selection = FamilyActivitySelection()
    @State private var isPickerPresented = false

    private var totalSelected: Int {
        selection.applicationTokens.count + selection.categoryTokens.count
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text("Choose Apps")
                    .font(.largeTitle.bold())

                Text("Select apps where you want a mindful pause")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Selection summary
            if totalSelected > 0 {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)

                    if selection.applicationTokens.count > 0 {
                        Text("\(selection.applicationTokens.count) app\(selection.applicationTokens.count == 1 ? "" : "s") selected")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if selection.categoryTokens.count > 0 {
                        Text("\(selection.categoryTokens.count) categor\(selection.categoryTokens.count == 1 ? "y" : "ies") selected")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Spacer()

            VStack(spacing: 16) {
                Button(action: { isPickerPresented = true }) {
                    Label(
                        totalSelected > 0 ? "Edit Selection" : "Select Apps",
                        systemImage: "app.badge.checkmark"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button(action: completeOnboarding) {
                    Text("Finish Setup")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(totalSelected == 0 ? Color.gray : Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(totalSelected == 0)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
    }

    private func completeOnboarding() {
        // Save selection and apply shields
        ShieldManager.shared.saveSelection(selection)

        // Mark onboarding as complete
        appState.hasCompletedOnboarding = true
    }
}

#Preview {
    AppSelectionView()
        .environment(AppState())
}
