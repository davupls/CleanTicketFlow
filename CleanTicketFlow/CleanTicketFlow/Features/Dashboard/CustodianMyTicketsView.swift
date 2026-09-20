//
//  CustodianMyTicketsView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import SwiftUI
import SwiftData

private enum TicketFilter: String, CaseIterable {
    case open = "Open"
    case resolved = "Resolved"
}

struct CustodianMyTicketsView: View {
    @Query private var tickets: [Ticket]
    @State private var filter: TicketFilter = .open

    private var openTickets: [Ticket] {
        tickets.filter { $0.status == .open || $0.status == .enRoute || $0.status == .onSite }
    }

    private var resolvedTickets: [Ticket] {
        tickets.filter { $0.status == .resolved || $0.status == .closed }
    }

    private var filteredTickets: [Ticket] {
        filter == .open ? openTickets : resolvedTickets
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 8) {
                    ForEach(TicketFilter.allCases, id: \.self) { f in
                        let count = f == .open ? openTickets.count : resolvedTickets.count
                        Button {
                            filter = f
                        } label: {
                            Text("\(f.rawValue) · \(count)")
                                .font(.subheadline)
                                .fontWeight(filter == f ? .semibold : .regular)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(filter == f ? Color.accentColor : Color(.systemGray6))
                                .foregroundStyle(filter == f ? .white : .primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
            }

            if filteredTickets.isEmpty {
                Section {
                    Text(filter == .open ? "No open tickets" : "No resolved tickets")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            } else {
                Section {
                    ForEach(filteredTickets) { ticket in
                        NavigationLink(destination: TicketDetailView(ticket: ticket)) {
                            TicketRowView(ticket: ticket)
                        }
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle("My Tickets")
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
    }
}

#Preview {
    NavigationStack {
        CustodianMyTicketsView()
    }
    .modelContainer(for: Ticket.self, inMemory: true)
}
