//
//  AuthorizationManager.swift
//  Comma
//
//  Manages FamilyControls authorization.
//

import FamilyControls
import SwiftUI

@MainActor
@Observable
final class AuthorizationManager {
    private(set) var authorizationStatus: AuthorizationStatus = .notDetermined

    private let center = AuthorizationCenter.shared

    init() {
        checkCurrentStatus()
    }

    /// Requests FamilyControls authorization
    func requestAuthorization() async {
        do {
            try await center.requestAuthorization(for: .individual)
            authorizationStatus = .approved
        } catch {
            authorizationStatus = .denied
        }
    }

    /// Checks the current authorization status
    func checkCurrentStatus() {
        authorizationStatus = center.authorizationStatus
    }

    /// Returns true if authorization has been granted
    var isAuthorized: Bool {
        authorizationStatus == .approved
    }
}
