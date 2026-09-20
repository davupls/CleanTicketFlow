//
//  DispatcherDashboardView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/6/26.
//

import SwiftUI
import SwiftData

struct DispatcherDashboardView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DispatchQueueView()
            }
            .tabItem { Label("Queue", systemImage: "list.bullet.clipboard") }

            NavigationStack {
                TechniciansView()
            }
            .tabItem { Label("Technicians", systemImage: "person.2") }

            NavigationStack {
                Text("Parts")
                    .navigationTitle("Parts")
            }
            .tabItem { Label("Parts", systemImage: "wrench.and.screwdriver") }

            NavigationStack {
                DispatchReportsView()
            }
            .tabItem { Label("Reports", systemImage: "chart.bar") }

            NavigationStack {
                DispatcherProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}

#Preview {
    DispatcherDashboardView()
        .modelContainer(for: Ticket.self, inMemory: true)
}
