//
//  TechTicketRowView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import SwiftUI

struct TechTicketRowView: View {
    let ticket: Ticket

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(slaColor)
                .frame(width: 3)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 5) {
                // Ticket ID + ATM ID + status badge
                HStack(alignment: .center) {
                    Text("#\(ticket.ticketID) · ATM-\(ticket.atmID)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    statusBadge
                }

                // Issue description
                Text(ticket.descriptionText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                // Branch + ATM location
                if !ticket.locationSummary.isEmpty {
                    Text(ticket.locationSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // SLA label + prior visits
                HStack {
                    Text(slaDisplayLabel)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(slaColor)
                    Spacer()
                    Text(visitCountLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.leading, 10)
            .padding(.vertical, 6)
        }
        .padding(.vertical, 2)
    }

    // MARK: - SLA

    private var slaColor: Color {
        let r = ticket.slaRemaining
        if r <= 0       { return .red }
        if r < 2 * 3600 { return .red }
        if r < 4 * 3600 { return .orange }
        return .green
    }

    private var slaDisplayLabel: String {
        let r = ticket.slaRemaining
        let total = abs(r)
        let days  = Int(total) / 86400
        let hours = (Int(total) % 86400) / 3600
        let mins  = (Int(total) % 3600) / 60

        let timeString: String
        if days > 0 {
            timeString = "\(days)d \(hours)h"
        } else if hours > 0 {
            timeString = "\(hours)h \(mins)m"
        } else {
            timeString = "\(mins)m"
        }
        return r > 0 ? "SLA \(timeString) left" : "SLA exceeded by \(timeString)"
    }

    // MARK: - Status badge

    private var statusLabel: String {
        switch ticket.status {
        case .open:      return "Assigned"
        case .enRoute:   return "En Route"
        case .onSite:    return "On Site"
        case .resolved:  return "Resolved"
        case .closed:    return "Closed"
        case .cancelled: return "Cancelled"
        }
    }

    private var statusColor: Color {
        switch ticket.status {
        case .open:      return .purple
        case .enRoute:   return .blue
        case .onSite:    return .orange
        case .resolved:  return .green
        case .closed:    return .gray
        case .cancelled: return .red
        }
    }

    private var statusBadge: some View {
        Text(statusLabel)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(statusColor.opacity(0.15))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }

    // MARK: - Prior visits

    private var visitCountLabel: String {
        let count = SampleData.priorVisitCount(for: ticket.atmID)
        switch count {
        case 0:  return "First visit"
        case 1:  return "1 prior visit"
        default: return "\(count) prior visits"
        }
    }
}

#Preview {
    List {
        ForEach(SampleData.tickets.prefix(4), id: \.id) { ticket in
            TechTicketRowView(ticket: ticket)
        }
    }
}
