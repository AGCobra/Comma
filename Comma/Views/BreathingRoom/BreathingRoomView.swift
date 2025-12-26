//
//  BreathingRoomView.swift
//  Comma
//
//  Full-screen breathing exercise experience.
//

import SwiftUI

struct BreathingRoomView: View {
    @Environment(AppState.self) private var appState

    @State private var progress: Double = 0
    @State private var isComplete = false
    @State private var breathPhase: GradientOrbView.BreathPhase = .inhale
    @State private var timerTask: Task<Void, Never>?
    @State private var instructionText = "Breathe in..."

    // Get user-configured breathing duration
    private var totalDuration: Double {
        Double(AppGroupManager.shared.breathingDurationSeconds)
    }

    // Breathing cycle phases scale proportionally to total duration
    // Base ratio: 4s inhale, 2s hold, 4s exhale (40%, 20%, 40%)
    private var inhaleDuration: Double { totalDuration * 0.4 }
    private var holdDuration: Double { totalDuration * 0.2 }
    private var exhaleDuration: Double { totalDuration * 0.4 }

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            VStack(spacing: 48) {
                Spacer()

                // Instruction text
                Text(isComplete ? "You're ready" : instructionText)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .animation(.easeInOut, value: instructionText)

                // Gradient orb
                GradientOrbView(progress: progress, breathPhase: breathPhase)
                    .frame(width: 200, height: 200)

                // Timer display
                Text(timeRemaining)
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .monospacedDigit()
                    .contentTransition(.numericText())

                Spacer()

                // Complete button (shown after exercise)
                if isComplete {
                    VStack(spacing: 16) {
                        Button(action: unlockAndContinue) {
                            Text("Continue to App")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.white)
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Button(action: goToDashboard) {
                            Text("I've changed my mind")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear(perform: startBreathing)
        .onDisappear {
            timerTask?.cancel()
        }
    }

    private var timeRemaining: String {
        let remaining = max(0, Int(ceil(totalDuration - (progress * totalDuration))))
        return "\(remaining)"
    }

    private func startBreathing() {
        HapticsManager.shared.prepareAll()

        timerTask = Task {
            let startTime = Date()
            var lastSecond: Int = -1

            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(startTime)
                let newProgress = min(1.0, elapsed / totalDuration)

                await MainActor.run {
                    progress = newProgress

                    // Update breath phase based on cycle
                    let cycleTime = elapsed.truncatingRemainder(dividingBy: totalDuration)
                    updateBreathPhase(cycleTime: cycleTime)

                    // Haptic tick each second
                    let currentSecond = Int(elapsed)
                    if currentSecond != lastSecond {
                        lastSecond = currentSecond
                        HapticsManager.shared.tick()
                    }
                }

                if newProgress >= 1.0 {
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isComplete = true
                        }
                        HapticsManager.shared.exerciseComplete()
                    }
                    break
                }

                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }

    private func updateBreathPhase(cycleTime: Double) {
        if cycleTime < inhaleDuration {
            // Inhale phase
            if breathPhase != .inhale {
                breathPhase = .inhale
                instructionText = "Breathe in..."
                HapticsManager.shared.breatheIn()
            }
        } else if cycleTime < inhaleDuration + holdDuration {
            // Hold phase
            if breathPhase != .hold {
                breathPhase = .hold
                instructionText = "Hold..."
            }
        } else {
            // Exhale phase
            if breathPhase != .exhale {
                breathPhase = .exhale
                instructionText = "Breathe out..."
                HapticsManager.shared.breatheOut()
            }
        }
    }

    private func unlockAndContinue() {
        // Log the successful breathing event
        Task {
            do {
                let storage = try PauseEventStorage()
                try await storage.logEvent(.breathedThenOpened)
            } catch {
                print("Failed to log event: \(error)")
            }
        }

        // Temporarily unlock shields
        ShieldManager.shared.temporarilyUnlock()

        // Clear breathing room state
        appState.breathingCompleted()
    }

    private func goToDashboard() {
        // Log as mindful close since they chose not to continue
        Task {
            do {
                let storage = try PauseEventStorage()
                try await storage.logEvent(.mindfulClose)
            } catch {
                print("Failed to log event: \(error)")
            }
        }

        // Clear breathing room state without unlocking
        appState.breathingCompleted()
    }
}

#Preview {
    BreathingRoomView()
        .environment(AppState())
}
