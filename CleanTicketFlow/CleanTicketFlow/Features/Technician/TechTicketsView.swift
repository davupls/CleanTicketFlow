//
//  TechTicketsView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import SwiftUI
import SwiftData

private enum TechTicketFilter: String, CaseIterable {
    case assigned   = "Assigned"
    case inProgress = "In Progress"
    case completed  = "Completed today"
}

struct TechTicketsView: View {
    let technician: Technician
    @Environment(\.modelContext) private var modelContext
    @Query private var allTickets: [Ticket]

    @State private var searchText = ""
    @State private var filter: TechTicketFilter = .assigned

    // MARK: - Derived ticket collections

    private var myTickets: [Ticket] {
        allTickets
            .filter { $0.assignedTechID == technician.id }
            .sorted { $0.slaDueAt < $1.slaDueAt }
    }

    private var assignedTickets: [Ticket] {
        myTickets.filter { $0.status == .open }
    }

    private var inProgressTickets: [Ticket] {
        myTickets.filter { $0.status == .enRoute || $0.status == .onSite }
    }

    private var completedTodayTickets: [Ticket] {
        myTickets.filter {
            guard let c = $0.completedAt else { return false }
            return ($0.status == .resolved || $0.status == .closed) &&
                   Calendar.current.isDateInToday(c)
        }
    }

    private var filteredTickets: [Ticket] {
        let base: [Ticket]
        switch filter {
        case .assigned:   base = assignedTickets
        case .inProgress: base = inProgressTickets
        case .completed:  base = completedTodayTickets
        }
        guard !searchText.isEmpty else { return base }
        return base.filter { t in
            t.ticketID.localizedCaseInsensitiveContains(searchText)
            || String(t.atmID).contains(searchText)
            || t.branch?.name.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    private func count(for f: TechTicketFilter) -> Int {
        switch f {
        case .assigned:   return assignedTickets.count
        case .inProgress: return inProgressTickets.count
        case .completed:  return completedTodayTickets.count
        }
    }

    // MARK: - Stats

    private var openCount: Int {
        myTickets.filter { $0.status != .resolved && $0.status != .closed && $0.status != .cancelled }.count
    }

    private var atRiskCount: Int {
        myTickets.filter { $0.isAtRisk && $0.status != .resolved && $0.status != .closed && $0.status != .cancelled }.count
    }

    private var partsLowCount: Int {
        SampleData.vanInventory.filter(\.isBelowMinimum).count
    }

    // MARK: - Helpers

    private var zoneRegion: String {
        switch technician.zone {
        case 1: return "Winter Park"
        case 2: return "Waterford Lakes"
        case 3: return "East Orlando"
        case 4: return "Lake Nona"
        case 5: return "Downtown Orlando"
        case 6: return "Kissimmee"
        default: return "Zone \(technician.zone)"
        }
    }

    // MARK: - Body

    var body: some View {
        List {
            filterSection
            statsSection
            ticketsSection
        }
        .listSectionSpacing(.compact)
        .searchable(text: $searchText, prompt: "Ticket #, ATM ID, or branch")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                TechInitialsCircle(initials: technician.initials, size: 30)
            }
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("My Tickets")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("\(technician.name) · Zone \(technician.zone) · \(zoneRegion)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                notificationBell
            }
        }
        .onAppear {
            if allTickets.isEmpty {
                SampleData.tickets.forEach { modelContext.insert($0) }
            }
        }
    }

    // MARK: - Toolbar

    private var notificationBell: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "bell")
            if atRiskCount > 0 {
                Text("\(atRiskCount)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(3)
                    .background(.red)
                    .clipShape(Circle())
                    .offset(x: 8, y: -8)
            }
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TechTicketFilter.allCases, id: \.self) { f in
                        Button {
                            filter = f
                        } label: {
                            Text("\(f.rawValue) · \(count(for: f))")
                                .font(.subheadline)
                                .fontWeight(filter == f ? .semibold : .regular)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(filter == f ? Color.accentColor : Color(.systemGray6))
                                .foregroundStyle(filter == f ? Color.white : Color.primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        Section {
            HStack(spacing: 10) {
                TechStatCard(title: "Open",        value: "\(openCount)",     color: nil)
                TechStatCard(title: "SLA at risk", value: "\(atRiskCount)",   color: .red)
                TechStatCard(title: "Parts low",   value: "\(partsLowCount)", color: .orange)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
    }

    // MARK: - Tickets Section

    private var ticketsSection: some View {
        Section {
            ForEach(filteredTickets) { ticket in
                NavigationLink(destination: TechTicketDetailView(ticket: ticket, technician: technician)) {
                    TechTicketRowView(ticket: ticket)
                }
            }
        } header: {
            HStack {
                Text("Sorted by SLA deadline")
                Spacer()
                Text("Nearest first")
            }
        }
    }
}

// MARK: - Stat Card

private struct TechStatCard: View {
    let title: String
    let value: String
    let color: Color?

    private var displayColor: Color { color ?? Color(.label) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(color != nil ? displayColor : Color.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(displayColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(color != nil ? displayColor.opacity(0.1) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationStack {
        TechTicketsView(technician: SampleData.technicians[0])
    }
    .modelContainer(for: Ticket.self, inMemory: true)
}
