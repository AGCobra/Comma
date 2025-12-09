//
//  DashboardView.swift
//  Comma
//
//  Main dashboard showing statistics and quick actions.
//

import SwiftUI
import Combine
import FamilyControls

struct DashboardView: View {
    @State private var stats: (breathed: Int, mindful: Int, attempted: Int) = (0, 0, 0)
    @State private var showSettings = false
    @State private var isPickerPresented = false
    @State private var selection: FamilyActivitySelection

    init() {
        _selection = State(initialValue: ShieldManager.shared.selectedApps)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Today's summary
                    VStack(spacing: 16) {
                        HStack {
                            Text("Today")
                                .font(.headline)
                            Spacer()
                        }

                        HStack(spacing: 16) {
                            StatsCardView(
                                title: "Breaths Taken",
                                value: "\(stats.breathed)",
                                icon: "wind",
                                color: .green
                            )

                            StatsCardView(
                                title: "Mindful Closes",
                                value: "\(stats.mindful)",
                                icon: "hand.raised.fill",
                                color: .blue
                            )
                        }
                    }

                    // Unlock status
                    if AppGroupManager.shared.isUnlocked {
                        UnlockStatusCard()
                    }

                    // Quick actions
                    VStack(spacing: 16) {
                        HStack {
                            Text("Quick Actions")
                                .font(.headline)
                            Spacer()
                        }

                        Button(action: { isPickerPresented = true }) {
                            HStack {
                                Label("Edit Protected Apps", systemImage: "app.badge.checkmark")
                                Spacer()
                                Text("\(totalSelected)")
                                    .foregroundStyle(.secondary)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                                    .font(.footnote)
                            }
                            .padding()
                            .background(.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .foregroundStyle(.primary)
                    }

                    // Motivational message
                    if stats.breathed > 0 || stats.mindful > 0 {
                        MotivationalCard(stats: stats)
                    }
                }
                .padding()
            }
            .navigationTitle("Comma")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
            .onChange(of: selection) { _, newSelection in
                ShieldManager.shared.saveSelection(newSelection)
            }
            .refreshable {
                await loadStats()
            }
        }
        .task {
            await loadStats()
        }
    }

    private var totalSelected: Int {
        selection.applicationTokens.count + selection.categoryTokens.count
    }

    private func loadStats() async {
        do {
            let storage = try PauseEventStorage()
            let result = try await storage.todaysStats()
            await MainActor.run {
                withAnimation {
                    stats = result
                }
            }
        } catch {
            print("Failed to load stats: \(error)")
        }
    }
}

struct UnlockStatusCard: View {
    @State private var timeRemaining: String = ""
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            Image(systemName: "lock.open.fill")
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text("Apps Unlocked")
                    .font(.subheadline.bold())
                Text("Re-locks in \(timeRemaining)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.green.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
        .onAppear {
            updateTimeRemaining()
        }
    }

    private func updateTimeRemaining() {
        guard let expiration = AppGroupManager.shared.unlockExpirationDate else {
            timeRemaining = "0:00"
            return
        }

        let remaining = expiration.timeIntervalSince(Date())
        if remaining <= 0 {
            timeRemaining = "0:00"
        } else {
            let minutes = Int(remaining) / 60
            let seconds = Int(remaining) % 60
            timeRemaining = String(format: "%d:%02d", minutes, seconds)
        }
    }
}

struct MotivationalCard: View {
    let stats: (breathed: Int, mindful: Int, attempted: Int)

    private var message: String {
        let total = stats.breathed + stats.mindful
        if total >= 10 {
            return "Amazing mindfulness today! You've paused \(total) times."
        } else if total >= 5 {
            return "Great progress! Keep building that awareness."
        } else if stats.mindful > stats.breathed {
            return "Strong willpower! You're choosing presence over scrolling."
        } else {
            return "Every breath creates space for intention."
        }
    }

    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(.yellow)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .background(.yellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DashboardView()
}
