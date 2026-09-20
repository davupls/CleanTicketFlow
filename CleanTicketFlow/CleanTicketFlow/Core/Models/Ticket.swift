//
//  Ticket.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/5/26.
//

import Foundation
import SwiftData

enum TicketStatus: String, CaseIterable, Codable {
    case open = "Open"
    case enRoute = "En Route"
    case onSite = "On Site"
    case resolved = "Resolved"
    case closed = "Closed"
    case cancelled = "Cancelled"
}

enum Priority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

enum IssueType: String, CaseIterable, Codable {
    case hardware = "Hardware"
    case software = "Software"
    case network = "Network"
    case cash = "Cash"
    case other = "Other"
}

@Model
class Ticket: Identifiable {
    var id: UUID
    var ticketID: String
    var atmID: Int
    var createdByUserID: Int
    var assignedTechID: Int?
    var issueType: IssueType
    var priority: Priority
    var status: TicketStatus
    var descriptionText: String
    var slaDueAt: Date
    var createdAt: Date
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        ticketID: String,
        atmID: Int,
        createdByUserID: Int,
        assignedTechID: Int? = nil,
        issueType: IssueType,
        priority: Priority,
        status: TicketStatus = .open,
        descriptionText: String,
        slaDueAt: Date,
        createdAt: Date = .now,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.ticketID = ticketID
        self.atmID = atmID
        self.createdByUserID = createdByUserID
        self.assignedTechID = assignedTechID
        self.issueType = issueType
        self.priority = priority
        self.status = status
        self.descriptionText = descriptionText
        self.slaDueAt = slaDueAt
        self.createdAt = createdAt
        self.completedAt = completedAt
    }

    // MARK: - SLA

    var slaRemaining: TimeInterval {
        slaDueAt.timeIntervalSinceNow
    }

    var isAtRisk: Bool {
        slaRemaining > 0 && slaRemaining < (4 * 3600)
    }

    var isSLAMet: Bool {
        guard let completedAt else { return false }
        return completedAt <= slaDueAt
    }

    var slaLabel: String {
        let total = abs(slaRemaining)
        let h = Int(total) / 3600
        let m = (Int(total) % 3600) / 60
        let timeString = h > 0 ? "\(h)h \(m)m" : "\(m)m"
        return slaRemaining > 0 ? "SLA \(timeString) left" : "SLA exceeded by \(timeString)"
    }

    // MARK: - Lookups (non-persisted, derived from SampleData)

    var atm: ATM? {
        SampleData.atm(for: self)
    }

    var branch: Branch? {
        SampleData.branch(for: self)
    }

    var zone: Int? {
        atm?.zone
    }

    var assignedTech: Technician? {
        guard let id = assignedTechID else { return nil }
        return SampleData.technician(id: id)
    }

    var locationSummary: String {
        let parts: [String?] = [branch?.name, atm?.location, zone.map { "Zone \($0)" }]
        return parts.compactMap { $0 }.joined(separator: " · ")
    }
}
