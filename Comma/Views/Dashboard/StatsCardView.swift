//
//  StatsCardView.swift
//  Comma
//
//  Reusable card component for displaying statistics.
//

import SwiftUI

struct StatsCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .contentTransition(.numericText())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HStack {
        StatsCardView(
            title: "Breaths Taken",
            value: "12",
            icon: "wind",
            color: .green
        )

        StatsCardView(
            title: "Mindful Closes",
            value: "5",
            icon: "hand.raised.fill",
            color: .blue
        )
    }
    .padding()
}
