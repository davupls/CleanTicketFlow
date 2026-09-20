//
//  CleanTicketFlowTests.swift
//  CleanTicketFlowTests
//
//  Created by David Mclean on 9/16/26.
//

import Testing
@testable import CleanTicketFlow

struct CleanTicketFlowTests {

    // Bug report: logging in with no password entered should tell the user
    // a password is required. Instead, AuthService.authenticate(email:password:)
    // returns nil the same way it does for any wrong credentials, so
    // LoginView.swift always falls back to the generic
    // "Incorrect email or password." text (see LoginView.swift line 77) with
    // no explanation that the password field is empty.
    // This test documents the expected message and is expected to FAIL
    // against the current implementation.
    @Test func loginWithNoPasswordShowsPasswordRequiredMessage() async throws {
        let role = AuthService.shared.authenticate(email: "test@test.com", password: "")
        #expect(role == nil, "empty password should not authenticate")

        let expectedMessage = "Password is required."
        let actualMessage = "Incorrect email or password." // LoginView.swift:77

        #expect(actualMessage == expectedMessage)
    }

    // Logging in with a valid, seeded email/password pair should authenticate
    // and hand back the matching role, which is what routes the user to
    // their main screen (see ContentView's role switch).
    @Test func loginWithCorrectCredentialsAuthenticatesUser() async throws {
        let role = AuthService.shared.authenticate(email: "test@test.com", password: "Atm$2026!")

        guard case .custodian = role else {
            Issue.record("Expected .custodian role for valid credentials, got \(String(describing: role))")
            return
        }
    }

}
