//
//  PauseEvent.swift
//  Comma
//
//  SwiftData model for tracking pause events.
//

import Foundation
import SwiftData

/// Represents the outcome of a pause interaction
enum PauseOutcome: String, Codable, CaseIterable {
    /// User completed breathing exercise and opened the app
    case breathedThenOpened
    /// User chose to close mindfully without opening the app
    case mindfulClose
    /// User attempted to enter (tapped primary button)
    case attemptedEntry
}

/// Records each time a user interacts with a shield
@Model
final class PauseEvent {
    var id: UUID
    var timestamp: Date
    /// Encoded ApplicationToken data (opaque)
    var appTokenData: Data?
    /// The outcome as a string (PauseOutcome.rawValue)
    var outcome: String

    init(outcome: PauseOutcome, appTokenData: Data? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.appTokenData = appTokenData
        self.outcome = outcome.rawValue
    }

    /// Parses the outcome string back to enum
    var parsedOutcome: PauseOutcome {
        PauseOutcome(rawValue: outcome) ?? .attemptedEntry
    }
}
