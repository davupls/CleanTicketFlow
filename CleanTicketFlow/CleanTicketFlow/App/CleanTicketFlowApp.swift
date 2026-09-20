//
//  CleanTicketFlowApp.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/4/26.
//

import SwiftUI
import SwiftData

@main
struct CleanTicketFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Ticket.self)
    }
}
