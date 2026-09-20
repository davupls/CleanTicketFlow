//
//  AppEnvironment.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import SwiftUI

private struct SignOutKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var signOut: () -> Void {
        get { self[SignOutKey.self] }
        set { self[SignOutKey.self] = newValue }
    }
}
