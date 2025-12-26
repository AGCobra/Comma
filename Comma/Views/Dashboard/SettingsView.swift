//
//  SettingsView.swift
//  Comma
//
//  App settings and configuration.
//

import SwiftUI
import FamilyControls

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPickerPresented = false
    @State private var selection: FamilyActivitySelection
    @State private var unlockDuration: Int
    @State private var breathingDuration: Int

    init() {
        _selection = State(initialValue: ShieldManager.shared.selectedApps)
        _unlockDuration = State(initialValue: AppGroupManager.shared.unlockDurationMinutes)
        _breathingDuration = State(initialValue: AppGroupManager.shared.breathingDurationSeconds)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: { isPickerPresented = true }) {
                        HStack {
                            Label("Protected Apps", systemImage: "app.badge.checkmark")
                            Spacer()
                            Text("\(totalSelected)")
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                                .font(.footnote)
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("App Management")
                } footer: {
                    Text("Select which apps will show a breathing pause before opening.")
                }

                Section {
                    Picker(selection: $unlockDuration) {
                        ForEach(SharedConstants.unlockDurationOptions, id: \.self) { minutes in
                            Text("\(minutes) minutes").tag(minutes)
                        }
                    } label: {
                        Label("Unlock Duration", systemImage: "timer")
                    }
                    .onChange(of: unlockDuration) { _, newValue in
                        AppGroupManager.shared.unlockDurationMinutes = newValue
                    }

                    Picker(selection: $breathingDuration) {
                        ForEach(SharedConstants.breathingDurationOptions, id: \.self) { seconds in
                            Text("\(seconds) seconds").tag(seconds)
                        }
                    } label: {
                        Label("Breath Duration", systemImage: "lungs.fill")
                    }
                    .onChange(of: breathingDuration) { _, newValue in
                        AppGroupManager.shared.breathingDurationSeconds = newValue
                    }
                } header: {
                    Text("Timing")
                } footer: {
                    Text("Unlock duration is how long apps stay accessible after breathing. Breath duration is the length of the breathing exercise.")
                }

                Section {
                    Link(destination: URL(string: "https://support.apple.com/screen-time")!) {
                        Label("Screen Time Help", systemImage: "questionmark.circle")
                    }
                } header: {
                    Text("Support")
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
            .onChange(of: selection) { _, newSelection in
                ShieldManager.shared.saveSelection(newSelection)
            }
        }
    }

    private var totalSelected: Int {
        selection.applicationTokens.count + selection.categoryTokens.count
    }
}

#Preview {
    SettingsView()
}
