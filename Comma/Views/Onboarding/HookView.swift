//
//  HookView.swift
//  Comma
//
//  First onboarding screen - the value proposition hook.
//

import SwiftUI

struct HookView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // App icon/logo
            Image(systemName: "pause.circle.fill")
                .font(.system(size: 120))
                .foregroundStyle(Color.accentColor)
                .symbolEffect(.pulse, options: .repeating)

            VStack(spacing: 16) {
                Text("One Breath")
                    .font(.largeTitle.bold())

                Text("What if you had 10 seconds to choose... instead of react?")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()

            Button(action: onContinue) {
                Text("Get Started")
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

#Preview {
    HookView(onContinue: {})
}
