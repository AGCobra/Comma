//
//  HowItWorksView.swift
//  Comma
//
//  Second onboarding screen - explains how the app works.
//

import SwiftUI

struct HowItWorksView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("How it Works")
                .font(.largeTitle.bold())

            VStack(alignment: .leading, spacing: 24) {
                StepRow(
                    number: 1,
                    title: "Choose Apps",
                    description: "Select apps you want to be more mindful about"
                )

                StepRow(
                    number: 2,
                    title: "Pause Appears",
                    description: "When you open those apps, a gentle pause appears"
                )

                StepRow(
                    number: 3,
                    title: "Take a Breath",
                    description: "Complete a 10-second breathing exercise"
                )

                StepRow(
                    number: 4,
                    title: "Decide",
                    description: "App unlocks for 15 minutes, or close mindfully"
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }
}

struct StepRow: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)")
                .font(.headline)
                .foregroundStyle(Color.accentColor)
                .frame(width: 32, height: 32)
                .background(Color.accentColor.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    HowItWorksView(onContinue: {})
}
