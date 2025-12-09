//
//  PauseEventStorage.swift
//  Comma
//
//  Thread-safe storage actor for pause events and app mappings.
//

import Foundation
import SwiftData

actor PauseEventStorage {
    private let modelContainer: ModelContainer

    init() throws {
        let schema = Schema([PauseEvent.self, AppTokenMapping.self])
        let config = ModelConfiguration(
            schema: schema,
            url: AppGroupManager.shared.containerURL.appendingPathComponent("CommaData.store"),
            cloudKitDatabase: .none
        )
        self.modelContainer = try ModelContainer(for: schema, configurations: config)
    }

    // MARK: - Pause Events

    /// Logs a new pause event
    func logEvent(_ outcome: PauseOutcome, appTokenData: Data? = nil) throws {
        let context = ModelContext(modelContainer)
        let event = PauseEvent(outcome: outcome, appTokenData: appTokenData)
        context.insert(event)
        try context.save()
    }

    /// Fetches events since a given date
    func fetchEvents(since date: Date) throws -> [PauseEvent] {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<PauseEvent> { $0.timestamp >= date }
        let descriptor = FetchDescriptor<PauseEvent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    /// Returns today's statistics
    func todaysStats() throws -> (breathed: Int, mindful: Int, attempted: Int) {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let events = try fetchEvents(since: startOfDay)

        var breathed = 0
        var mindful = 0
        var attempted = 0

        for event in events {
            switch event.parsedOutcome {
            case .breathedThenOpened:
                breathed += 1
            case .mindfulClose:
                mindful += 1
            case .attemptedEntry:
                attempted += 1
            }
        }

        return (breathed, mindful, attempted)
    }

    // MARK: - App Token Mappings

    /// Saves or updates an app token mapping
    func saveMapping(tokenData: Data, displayName: String, bundleIdentifier: String? = nil) throws {
        let context = ModelContext(modelContainer)

        // Check if mapping already exists
        let predicate = #Predicate<AppTokenMapping> { $0.tokenData == tokenData }
        let descriptor = FetchDescriptor<AppTokenMapping>(predicate: predicate)
        let existing = try context.fetch(descriptor)

        if let existingMapping = existing.first {
            existingMapping.displayName = displayName
            existingMapping.bundleIdentifier = bundleIdentifier
        } else {
            let mapping = AppTokenMapping(
                tokenData: tokenData,
                displayName: displayName,
                bundleIdentifier: bundleIdentifier
            )
            context.insert(mapping)
        }

        try context.save()
    }

    /// Gets the display name for a token
    func getDisplayName(for tokenData: Data) throws -> String? {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<AppTokenMapping> { $0.tokenData == tokenData }
        let descriptor = FetchDescriptor<AppTokenMapping>(predicate: predicate)
        let results = try context.fetch(descriptor)
        return results.first?.displayName
    }

    /// Gets all app mappings
    func getAllMappings() throws -> [AppTokenMapping] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<AppTokenMapping>(
            sortBy: [SortDescriptor(\.displayName)]
        )
        return try context.fetch(descriptor)
    }
}
