//
//  TicketRowView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/5/26.
//

import SwiftUI

struct TicketRowView: View {
    let ticket: Ticket

    private var atm: ATM? {
        SampleData.atms.first { $0.id == ticket.atmID }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("#\(ticket.ticketID) · ATM-\(ticket.atmID)\(atm.map { " · \($0.location)" } ?? "")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                statusBadge
            }

            Text(ticket.descriptionText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)

            Text(subtitleText)
                .font(.caption)
                .foregroundStyle(.secondary)

            TicketProgressBar(status: ticket.status, isAssigned: ticket.assignedTechID != nil)
                .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }

    private var statusBadge: some View {
        Text(ticket.status.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(statusColor.opacity(0.15))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }

    private var subtitleText: String {
        if ticket.status == .resolved, let completedAt = ticket.completedAt {
            let elapsed = completedAt.timeIntervalSince(ticket.createdAt)
            let h = Int(elapsed) / 3600
            let m = (Int(elapsed) % 3600) / 60
            let duration = h > 0 ? "\(h)h \(m)m" : "\(m)m"
            return "Resolved \(completedAt.formatted(.relative(presentation: .named))) · \(duration)"
        }
        return "Reported \(ticket.createdAt.formatted(.relative(presentation: .named))) · Priority: \(ticket.priority.rawValue.lowercased())"
    }

    private var statusColor: Color {
        switch ticket.status {
        case .open:      return .orange
        case .enRoute:   return .blue
        case .onSite:    return .orange
        case .resolved:  return .green
        case .closed:    return .gray
        case .cancelled: return .red
        }
    }
}

// MARK: - Progress Bar

private struct TicketProgressBar: View {
    let status: TicketStatus
    let isAssigned: Bool

    private var completedStep: Int {
        switch status {
        case .open:              return isAssigned ? 1 : 0
        case .enRoute, .onSite:  return 2
        case .resolved, .closed: return 3
        case .cancelled:         return 0
        }
    }

    private let stepLabels = ["Submitted", "Assigned", "In progress", "Resolved"]

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<4, id: \.self) { step in
                VStack(alignment: .leading, spacing: 3) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(segmentColor(for: step))
                        .frame(height: 4)
                    Text(stepLabels[step])
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
        }
    }

    private func segmentColor(for step: Int) -> Color {
        guard step <= completedStep else { return Color(.systemGray5) }
        if step == 2 && (status == .enRoute || status == .onSite) { return .orange }
        return .green
    }
}

#Preview {
    List {
        ForEach(SampleData.tickets) { ticket in
            TicketRowView(ticket: ticket)
        }
    }
}
