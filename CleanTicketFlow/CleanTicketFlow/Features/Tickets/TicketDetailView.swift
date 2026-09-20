//
//  TicketDetailView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/6/26.
//

import SwiftUI

struct TicketDetailView: View {
    let ticket: Ticket

    private var atm: ATM? {
        SampleData.atms.first { $0.id == ticket.atmID }
    }

    var body: some View {
        List {
            headerSection

            if ticket.status == .enRoute || ticket.status == .onSite {
                technicianBanner
            }

            statusTimelineSection
            reportSection
            actionsSection
        }
        .navigationTitle("#\(ticket.ticketID)")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(ticket.status.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .foregroundStyle(statusColor)
                    .clipShape(Capsule())

                Text(ticket.descriptionText)
                    .font(.title3)
                    .fontWeight(.semibold)

                if let atm {
                    Label("ATM-\(atm.id) · \(atm.location)", systemImage: "building.columns")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Label(
                    "Reported \(ticket.createdAt.formatted(.relative(presentation: .named)))",
                    systemImage: "clock"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var technicianBanner: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .foregroundStyle(.blue)
                    .padding(.top, 2)
                Text("A technician is working on it now. You'll get a notification when it's resolved.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var statusTimelineSection: some View {
        Section("Status") {
            StatusStepRow(
                label: "Submitted",
                detail: "by you",
                timestamp: ticket.createdAt,
                isComplete: true
            )
            StatusStepRow(
                label: "Assigned to a technician",
                detail: nil,
                timestamp: nil,
                isComplete: ticket.assignedTechID != nil
            )
            StatusStepRow(
                label: "In Progress",
                detail: "technician on site",
                timestamp: nil,
                isComplete: ticket.status == .enRoute || ticket.status == .onSite || ticket.status == .resolved || ticket.status == .closed
            )
            StatusStepRow(
                label: "Resolved",
                detail: nil,
                timestamp: ticket.completedAt,
                isComplete: ticket.completedAt != nil
            )
        }
    }

    private var reportSection: some View {
        Section("Your report") {
            Text(ticket.descriptionText)
                .font(.subheadline)
        }
    }

    private var actionsSection: some View {
        Section {
            Button("Add a comment") { }
            Button("Cancel ticket", role: .destructive) { }
        }
    }

    // MARK: - Helpers

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

// MARK: - StatusStepRow

private struct StatusStepRow: View {
    let label: String
    let detail: String?
    let timestamp: Date?
    let isComplete: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isComplete ? .green : Color(.systemGray4))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(isComplete ? .primary : .secondary)

                if let timestamp {
                    HStack(spacing: 4) {
                        Text(timestamp.formatted(date: .abbreviated, time: .shortened))
                        if let detail {
                            Text("· \(detail)")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TicketDetailView(ticket: SampleData.tickets[0])
    }
}
