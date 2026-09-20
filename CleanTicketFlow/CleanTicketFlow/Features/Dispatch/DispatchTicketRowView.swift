//
//  DispatchTicketRowView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/6/26.
//

import SwiftUI

struct DispatchTicketRowView: View {
    let ticket: Ticket
    var onAssignTech: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left accent bar — visible on at-risk tickets
            RoundedRectangle(cornerRadius: 2)
                .fill(ticket.isAtRisk ? slaColor : Color.clear)
                .frame(width: 3)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 5) {
                // Ticket ID + status badge
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

                // Location summary
                if !ticket.locationSummary.isEmpty {
                    Text(ticket.locationSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // SLA + action row
                HStack(alignment: .center) {
                    Text(ticket.slaLabel)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(slaColor)

                    Spacer()

                    if ticket.assignedTechID == nil {
                        Button("Assign tech") {
                            onAssignTech?()
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .buttonStyle(.plain)
                        .foregroundStyle(Color.accentColor)
                    } else if let tech = ticket.assignedTech {
                        HStack(spacing: 5) {
                            TechInitialsCircle(initials: tech.initials, size: 20)
                            Text("\(tech.name) · \(tech.availability.label.lowercased())")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.leading, 10)
            .padding(.vertical, 6)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Helpers

    private var slaColor: Color {
        let r = ticket.slaRemaining
        if r <= 0            { return .red }
        if r < 2 * 3600      { return .red }
        if r < 4 * 3600      { return .orange }
        return .green
    }

    private var statusLabel: String {
        switch ticket.status {
        case .open where ticket.assignedTechID == nil: return "Unassigned"
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
        case .open where ticket.assignedTechID == nil: return .orange
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
}

// MARK: - Reusable tech initials circle

struct TechInitialsCircle: View {
    let initials: String
    var size: CGFloat = 28

    var body: some View {
        Circle()
            .fill(Color.accentColor.opacity(0.85))
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .semibold))
                    .foregroundStyle(.white)
            )
    }
}

#Preview {
    List {
        ForEach(SampleData.tickets) { ticket in
            DispatchTicketRowView(ticket: ticket)
        }
    }
}
