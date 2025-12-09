//
//  AppTokenMapping.swift
//  Comma
//
//  SwiftData model for mapping opaque tokens to app names.
//

import Foundation
import SwiftData

/// Maps an opaque ApplicationToken to a human-readable app name
@Model
final class AppTokenMapping {
    var id: UUID
    /// Encoded ApplicationToken data
    var tokenData: Data
    /// Human-readable display name (e.g., "Instagram")
    var displayName: String
    /// Bundle identifier if available
    var bundleIdentifier: String?
    /// Date when this mapping was created
    var createdAt: Date

    init(tokenData: Data, displayName: String, bundleIdentifier: String? = nil) {
        self.id = UUID()
        self.tokenData = tokenData
        self.displayName = displayName
        self.bundleIdentifier = bundleIdentifier
        self.createdAt = Date()
    }
}
