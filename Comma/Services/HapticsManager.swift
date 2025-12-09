//
//  HapticsManager.swift
//  Comma
//
//  Manages haptic feedback for the breathing experience.
//

import UIKit

final class HapticsManager {
    static let shared = HapticsManager()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        prepareAll()
    }

    /// Prepares all generators for immediate use
    func prepareAll() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
    }

    /// Haptic for beginning of inhale
    func breatheIn() {
        impactMedium.impactOccurred()
    }

    /// Haptic for beginning of exhale
    func breatheOut() {
        impactLight.impactOccurred()
    }

    /// Haptic when breathing exercise is complete
    func exerciseComplete() {
        notification.notificationOccurred(.success)
    }

    /// Subtle tick for progress indication
    func tick() {
        impactLight.impactOccurred(intensity: 0.3)
    }

    /// Strong confirmation haptic
    func confirm() {
        impactHeavy.impactOccurred()
    }
}
