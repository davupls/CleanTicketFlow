//
//  TechnicianDashboardView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import SwiftUI
import SwiftData

struct TechnicianDashboardView: View {
    let technician: Technician

    var body: some View {
        TabView {
            NavigationStack {
                TechTicketsView(technician: technician)
            }
            .tabItem { Label("Tickets", systemImage: "ticket") }

            NavigationStack {
                VanInventoryDashboard(parts: SampleData.vanInventory)
            }
            .tabItem { Label("Van Inventory", systemImage: "shippingbox") }

            NavigationStack {
                TechnicianHistoryView(technician: technician)
            }
            .tabItem { Label("History", systemImage: "clock") }

            NavigationStack {
                TechnicianProfileView(technician: technician)
            }
            .tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}

#Preview {
    TechnicianDashboardView(technician: SampleData.technicians[0])
        .modelContainer(for: Ticket.self, inMemory: true)
}
