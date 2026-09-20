//
//  DispatchQueueView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/6/26.
//

import SwiftUI
import SwiftData

private enum DispatchFilter: String, CaseIterable {
    case all        = "All"
    case unassigned = "Unassigned"
    case assigned   = "Assigned"
    case inProgress = "In Progress"
    case completed  = "Completed"
    case cancelled  = "Cancelled"
}

struct DispatchQueueView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tickets: [Ticket]

    @State private var searchText = ""
    @State private var filter: DispatchFilter = .all
    @State private var assigningTicket: Ticket? = nil
    @State private var ticketToCancel: Ticket? = nil

    // MARK: - Derived counts

    private var unassignedTickets: [Ticket] {
        tickets.filter { $0.status == .open && $0.assignedTechID == nil }
    }
    private var atRiskTickets: [Ticket] {
        tickets.filter { $0.isAtRisk && $0.status != .resolved && $0.status != .closed }
    }
    private var inProgressTickets: [Ticket] {
        tickets.filter { $0.status == .enRoute || $0.status == .onSite }
    }
    private var closedTodayTickets: [Ticket] {
        tickets.filter {
            guard let c = $0.completedAt else { return false }
            return Calendar.current.isDateInToday(c)
        }
    }
    private var assignedTickets: [Ticket] {
        tickets.filter { $0.status == .open && $0.assignedTechID != nil }
    }
    private var completedTickets: [Ticket] {
        tickets.filter { $0.status == .resolved || $0.status == .closed }
    }

    private var activeTickets: [Ticket] {
        tickets.filter { $0.status != .resolved && $0.status != .closed && $0.status != .cancelled }
    }

    private var cancelledTickets: [Ticket] {
        tickets.filter { $0.status == .cancelled }
    }

    private var filteredTickets: [Ticket] {
        let base: [Ticket]
        switch filter {
        case .all:        base = activeTickets
        case .unassigned: base = unassignedTickets
        case .assigned:   base = assignedTickets
        case .inProgress: base = inProgressTickets
        case .completed:  base = completedTickets
        case .cancelled:  base = cancelledTickets
        }
        guard !searchText.isEmpty else { return base }
        return base.filter { t in
            t.ticketID.localizedCaseInsensitiveContains(searchText)
            || String(t.atmID).contains(searchText)
            || t.branch?.name.localizedCaseInsensitiveContains(searchText) == true
            || t.assignedTech?.name.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    private func count(for f: DispatchFilter) -> Int {
        switch f {
        case .all:        return activeTickets.count
        case .unassigned: return unassignedTickets.count
        case .assigned:   return assignedTickets.count
        case .inProgress: return inProgressTickets.count
        case .completed:  return completedTickets.count
        case .cancelled:  return cancelledTickets.count
        }
    }

    // MARK: - Body

    var body: some View {
        List {
            statsSection
            techniciansSection
            ticketsSection
        }
        .listSectionSpacing(.compact)
        .searchable(text: $searchText, prompt: "Ticket #, ATM ID, branch, or tech")
        .navigationTitle("Dispatch Queue")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                notificationButton
            }
        }
        .onAppear {
            if tickets.isEmpty {
                SampleData.tickets.forEach { modelContext.insert($0) }
            }
        }
        .sheet(item: $assigningTicket) { ticket in
            AssignTechSheet(ticket: ticket)
        }
        .alert("Cancel Ticket", isPresented: Binding(
            get: { ticketToCancel != nil },
            set: { if !$0 { ticketToCancel = nil } }
        )) {
            Button("Cancel Ticket", role: .destructive) {
                if let t = ticketToCancel {
                    t.status = .cancelled
                    t.completedAt = .now
                    ticketToCancel = nil
                }
            }
            Button("Keep Open", role: .cancel) { ticketToCancel = nil }
        } message: {
            if let t = ticketToCancel {
                Text("Ticket #\(t.ticketID) will be marked cancelled. This cannot be undone.")
            }
        }
    }

    // MARK: - Toolbar

    private var notificationButton: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "bell")
            if unassignedTickets.count > 0 {
                Text("\(unassignedTickets.count)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(3)
                    .background(.red)
                    .clipShape(Circle())
                    .offset(x: 8, y: -8)
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        Section {
            HStack(spacing: 10) {
                StatCard(title: "Unassigned",  count: unassignedTickets.count, color: .orange)
                StatCard(title: "At risk",     count: atRiskTickets.count,     color: .yellow)
                StatCard(title: "In progress", count: inProgressTickets.count, color: .blue)
                StatCard(title: "Closed today",count: closedTodayTickets.count, color: .green)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
    }

    // MARK: - Technicians Section

    private var techniciansSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(SampleData.technicians) { tech in
                        TechAvatarCell(technician: tech)
                    }
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        } header: {
            HStack {
                Text("Technicians · \(SampleData.technicians.count)")
                Spacer()
                Button("See all") { }
                    .font(.caption)
            }
        }
    }

    // MARK: - Tickets Section

    private var ticketsSection: some View {
        Section {
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DispatchFilter.allCases, id: \.self) { f in
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

            ForEach(filteredTickets) { ticket in
                NavigationLink(destination: TicketDetailView(ticket: ticket)) {
                    DispatchTicketRowView(ticket: ticket, onAssignTech: {
                        assigningTicket = ticket
                    })
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if ticket.status == .cancelled {
                        Button(role: .destructive) {
                            modelContext.delete(ticket)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } else {
                        Button(role: .destructive) {
                            ticketToCancel = ticket
                        } label: {
                            Label("Cancel", systemImage: "xmark.circle")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Tech Avatar Cell

private struct TechAvatarCell: View {
    let technician: Technician

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .bottomTrailing) {
                TechInitialsCircle(initials: technician.initials, size: 44)
                Circle()
                    .fill(availabilityDotColor)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
            }
            Text("Zone \(technician.zone)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var availabilityDotColor: Color {
        switch technician.availability {
        case .available: return .green
        case .onSite:    return .orange
        case .enRoute:   return .blue
        case .offShift:  return .gray
        }
    }
}

#Preview {
    NavigationStack {
        DispatchQueueView()
    }
    .modelContainer(for: Ticket.self, inMemory: true)
}
