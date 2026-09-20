//
//  ContentView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/4/26.
//

import SwiftUI

enum UserRole {
    case custodian
    case dispatcher
    case technician(Technician)
}

struct ContentView: View {
    @State private var activeRole: UserRole? = nil

    var body: some View {
        switch activeRole {
        case .custodian:
            CustodianDashboardView()
                .environment(\.signOut, { activeRole = nil })
        case .dispatcher:
            DispatcherDashboardView()
                .environment(\.signOut, { activeRole = nil })
        case .technician(let tech):
            TechnicianDashboardView(technician: tech)
                .environment(\.signOut, { activeRole = nil })
        case nil:
            LoginView(activeRole: $activeRole)
        }
    }
}

#Preview {
    ContentView()
}
