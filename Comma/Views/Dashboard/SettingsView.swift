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

    init() {
        _selection = State(initialValue: ShieldManager.shared.selectedApps)
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
                    HStack {
                        Label("Unlock Duration", systemImage: "timer")
                        Spacer()
                        Text("15 minutes")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Breath Duration", systemImage: "lungs.fill")
                        Spacer()
                        Text("10 seconds")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Timing")
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
