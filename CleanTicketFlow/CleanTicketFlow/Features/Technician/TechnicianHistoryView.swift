//
//  TechnicianHistoryView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import SwiftUI
import SwiftData

struct TechnicianHistoryView: View {
    let technician: Technician
    @Query private var allTickets: [Ticket]

    private var completedTickets: [Ticket] {
        allTickets
            .filter { $0.assignedTechID == technician.id && ($0.status == .resolved || $0.status == .closed) }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    private var slaMetCount: Int {
        completedTickets.filter { $0.isSLAMet }.count
    }

    private var slaPercentage: Int {
        guard !completedTickets.isEmpty else { return 0 }
        return Int((Double(slaMetCount) / Double(completedTickets.count)) * 100)
    }

    var body: some View {
        List {
            if !completedTickets.isEmpty {
                Section {
                    HStack(spacing: 12) {
                        HistoryStatCard(title: "Completed", value: "\(completedTickets.count)", color: nil)
                        HistoryStatCard(title: "SLA Met", value: "\(slaMetCount)", color: .green)
                        HistoryStatCard(title: "SLA Rate", value: "\(slaPercentage)%", color: slaPercentage >= 80 ? .green : .orange)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
            }

            if completedTickets.isEmpty {
                Section {
                    Text("No completed tickets yet")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 32)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            } else {
                Section("Resolved Tickets") {
                    ForEach(completedTickets) { ticket in
                        TechHistoryRow(ticket: ticket)
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle("History")
    }
}

// MARK: - History Row

private struct TechHistoryRow: View {
    let ticket: Ticket

    private var completedLabel: String {
        guard let completedAt = ticket.completedAt else { return "—" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: completedAt, relativeTo: .now)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("#\(ticket.ticketID) · ATM-\(ticket.atmID)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                let met = ticket.isSLAMet
                Text(met ? "SLA Met" : "SLA Missed")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(met ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
                    .foregroundStyle(met ? .green : .red)
                    .clipShape(Capsule())
            }

            Text(ticket.descriptionText)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            HStack {
                Text(ticket.locationSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Completed \(completedLabel)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Stat Card

private struct HistoryStatCard: View {
    let title: String
    let value: String
    let color: Color?

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color ?? .primary)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationStack {
        TechnicianHistoryView(technician: SampleData.technicians[0])
    }
    .modelContainer(for: Ticket.self, inMemory: true)
}
