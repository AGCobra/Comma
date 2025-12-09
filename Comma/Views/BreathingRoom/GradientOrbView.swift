//
//  GradientOrbView.swift
//  Comma
//
//  Animated gradient orb for the breathing exercise.
//

import SwiftUI

struct GradientOrbView: View {
    /// Progress from 0 to 1 representing completion of breathing exercise
    let progress: Double

    /// Current phase of the breath cycle
    let breathPhase: BreathPhase

    enum BreathPhase {
        case inhale
        case hold
        case exhale

        var scale: CGFloat {
            switch self {
            case .inhale: return 1.0
            case .hold: return 1.0
            case .exhale: return 0.6
            }
        }
    }

    @State private var animatedScale: CGFloat = 0.6
    @State private var rotation: Double = 0

    // Gradient colors - calm blues and purples
    private let colors: [Color] = [
        Color(red: 0.4, green: 0.5, blue: 0.9),   // Soft blue
        Color(red: 0.6, green: 0.4, blue: 0.8),   // Purple
        Color(red: 0.3, green: 0.6, blue: 0.9),   // Light blue
        Color(red: 0.5, green: 0.3, blue: 0.7),   // Deep purple
    ]

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            colors[0].opacity(0.3),
                            colors[1].opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .scaleEffect(animatedScale * 1.5)
                .blur(radius: 30)

            // Main orb with mesh-like gradient effect
            ZStack {
                // Base gradient circle
                Circle()
                    .fill(
                        AngularGradient(
                            colors: colors + [colors[0]],
                            center: .center,
                            startAngle: .degrees(rotation),
                            endAngle: .degrees(rotation + 360)
                        )
                    )
                    .blur(radius: 20)

                // Overlay radial gradient for depth
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.3),
                                colors[0].opacity(0.5),
                                colors[2].opacity(0.8)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .blendMode(.overlay)

                // Inner glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.4),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
            }
            .scaleEffect(animatedScale)
            .shadow(color: colors[0].opacity(0.5), radius: 40)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    .white.opacity(0.8),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .scaleEffect(1.15)
        }
        .onChange(of: breathPhase) { _, newPhase in
            withAnimation(.easeInOut(duration: newPhase == .inhale ? 4 : 4)) {
                animatedScale = newPhase.scale
            }
        }
        .onAppear {
            // Slow rotation for visual interest
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            animatedScale = breathPhase.scale
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        GradientOrbView(progress: 0.5, breathPhase: .inhale)
            .frame(width: 200, height: 200)
    }
}
