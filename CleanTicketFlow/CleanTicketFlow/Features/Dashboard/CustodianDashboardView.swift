//
//  CustodianDashboardView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/5/26.
//

import SwiftUI
import SwiftData

struct CustodianDashboardView: View {
    var body: some View {
        TabView {
            NavigationStack {
                CustodianHomeView()
            }
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                CustodianMyTicketsView()
            }
            .tabItem { Label("My Tickets", systemImage: "ticket") }

            NavigationStack {
                CustodianProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}

// MARK: - Home Tab

private struct CustodianHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tickets: [Ticket]

    @State private var showingRequestTicket = false

    var body: some View {
        List {
            reportSection
            atmSection
        }
        .listSectionSpacing(.compact)
        .navigationTitle("Lakeland Main Branch")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { } label: {
                    Image(systemName: "bell")
                        .overlay(alignment: .topTrailing) {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 3, y: -3)
                        }
                }
            }
        }
        .sheet(isPresented: $showingRequestTicket) {
            RequestTicketView()
        }
    }

    private var reportSection: some View {
        Section {
            Button {
                showingRequestTicket = true
            } label: {
                Label("Report an ATM issue", systemImage: "exclamationmark.triangle.fill")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    private var atmSection: some View {
        Section("Your ATMs · \(SampleData.atms.count)") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(SampleData.atms) { atm in
                    ATMStatusCard(atm: atm, tickets: tickets)
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
    }
}

// MARK: - ATM Status Card

private enum ATMStatus {
    case ok, techOnSite, scheduled, openIssue

    var label: String {
        switch self {
        case .ok:         return "OK"
        case .techOnSite: return "Tech on site"
        case .scheduled:  return "Scheduled"
        case .openIssue:  return "Open issue"
        }
    }

    var foregroundColor: Color {
        switch self {
        case .ok:         return .green
        case .techOnSite: return .orange
        case .scheduled:  return .blue
        case .openIssue:  return .red
        }
    }

    var backgroundColor: Color {
        switch self {
        case .ok:         return Color(.systemGray6)
        case .techOnSite: return .orange.opacity(0.12)
        case .scheduled:  return .blue.opacity(0.12)
        case .openIssue:  return .red.opacity(0.12)
        }
    }
}

private struct ATMStatusCard: View {
    let atm: ATM
    let tickets: [Ticket]

    private var status: ATMStatus {
        let active = tickets.filter {
            $0.atmID == atm.id && ($0.status == .open || $0.status == .enRoute || $0.status == .onSite)
        }
        if active.contains(where: { $0.status == .onSite }) { return .techOnSite }
        if active.contains(where: { $0.status == .enRoute }) { return .techOnSite }
        if active.contains(where: { $0.assignedTechID != nil }) { return .scheduled }
        if !active.isEmpty { return .openIssue }
        return .ok
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ATM-\(atm.id)")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text("\(atm.location) · \(status.label)")
                .font(.caption)
                .foregroundStyle(status.foregroundColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(status.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    CustodianDashboardView()
        .modelContainer(for: Ticket.self, inMemory: true)
}
