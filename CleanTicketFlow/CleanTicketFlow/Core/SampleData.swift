//
//  SampleData.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/5/26.
//

import Foundation

struct ATMHistoryEntry: Identifiable {
    let id: Int
    let atmID: Int
    let dateLabel: String
    let summary: String
    let techNote: String?
    let isWarning: Bool
}

struct SampleData {

    // MARK: - Technicians

    static let technicians: [Technician] = [
        Technician(user: User(id: 240230, name: "David M.",  email: "d.martinez@atomicatm.com", phone: nil, userRole: "technician", password: ""), initials: "DM", zone: 3, availability: .onSite),
        Technician(user: User(id: 240231, name: "James T.",  email: "j.torres@atomicatm.com",   phone: nil, userRole: "technician", password: ""), initials: "JT", zone: 1, availability: .available),
        Technician(user: User(id: 240232, name: "Alex L.",   email: "a.lewis@atomicatm.com",    phone: nil, userRole: "technician", password: ""), initials: "AL", zone: 5, availability: .available),
        Technician(user: User(id: 240233, name: "Marcus P.", email: "m.price@atomicatm.com",    phone: nil, userRole: "technician", password: ""), initials: "MP", zone: 2, availability: .onSite),
        Technician(user: User(id: 240234, name: "Ray S.",    email: "r.simmons@atomicatm.com",  phone: nil, userRole: "technician", password: ""), initials: "RS", zone: 4, availability: .offShift),
        Technician(user: User(id: 240235, name: "Carlos B.", email: "c.brooks@atomicatm.com",   phone: nil, userRole: "technician", password: ""), initials: "CB", zone: 6, availability: .available)
    ]

    // MARK: - Branches

    static let branches: [Branch] = [
        Branch(id: 1, name: "Lakeland Main Branch", address: "100 Main St",    city: "Lakeland",    state: "FL", zip: "33801", phone: nil),
        Branch(id: 2, name: "Lake Nona Branch",     address: "200 Nona Blvd",  city: "Orlando",     state: "FL", zip: "32827", phone: nil),
        Branch(id: 3, name: "Winter Park Village",  address: "300 Park Ave",   city: "Winter Park", state: "FL", zip: "32789", phone: nil),
        Branch(id: 4, name: "Waterford Lakes",      address: "400 Lake Dr",    city: "Orlando",     state: "FL", zip: "32828", phone: nil)
    ]

    // MARK: - ATMs

    static let atms: [ATM] = [
        ATM(id: 1001, branchID: 1, zone: 3, model: "NCR SelfServ 84", location: "Drive-up",  installedYear: 2019),
        ATM(id: 1002, branchID: 1, zone: 3, model: "NCR SelfServ 84", location: "Lobby",     installedYear: 2020),
        ATM(id: 1003, branchID: 1, zone: 3, model: "NCR SelfServ 80", location: "Drive-up",  installedYear: 2021),
        ATM(id: 1004, branchID: 2, zone: 3, model: "Diebold DN200",   location: "Drive-up",  installedYear: 2020),
        ATM(id: 1005, branchID: 3, zone: 1, model: "Diebold DN200",   location: "Lobby",     installedYear: 2022),
        ATM(id: 1006, branchID: 4, zone: 2, model: "NCR SelfServ 80", location: "Lobby",     installedYear: 2021)
    ]

    // MARK: - Tickets

    static let tickets: [Ticket] = [
        // Custodian slice
        Ticket(ticketID: "ABC123", atmID: 1001, createdByUserID: 9,
               assignedTechID: 240230, issueType: .hardware, priority: .critical,
               status: .onSite, descriptionText: "ATM no Power - No Display",
               slaDueAt: Date.now.addingTimeInterval(3600),
               createdAt: Date.now.addingTimeInterval(-3600)),
        Ticket(ticketID: "DEF123", atmID: 1002, createdByUserID: 8,
               assignedTechID: 240230, issueType: .hardware, priority: .medium,
               status: .open, descriptionText: "Customer Card Failed to Read",
               slaDueAt: Date.now.addingTimeInterval(8 * 3600),
               createdAt: Date.now.addingTimeInterval(-1800)),
        Ticket(ticketID: "GHI123", atmID: 1001, createdByUserID: 9,
               assignedTechID: nil, issueType: .cash, priority: .high,
               status: .open, descriptionText: "ENA Cash Jam - No Jam Found inside",
               slaDueAt: Date.now.addingTimeInterval(2 * 3600),
               createdAt: Date.now.addingTimeInterval(-3600)),

        // Dispatcher slice — variety across branches, zones, statuses
        Ticket(ticketID: "JKL047", atmID: 1004, createdByUserID: 10,
               assignedTechID: nil, issueType: .network, priority: .critical,
               status: .open, descriptionText: "ATM offline - No network connection",
               slaDueAt: Date.now.addingTimeInterval(1 * 3600 + 55 * 60),
               createdAt: Date.now.addingTimeInterval(-2 * 3600)),
        Ticket(ticketID: "MNO042", atmID: 1001, createdByUserID: 9,
               assignedTechID: 240230, issueType: .cash, priority: .critical,
               status: .onSite, descriptionText: "Cash dispenser jam - No cash out",
               slaDueAt: Date.now.addingTimeInterval(48 * 60),
               createdAt: Date.now.addingTimeInterval(-3 * 3600)),
        Ticket(ticketID: "PQR046", atmID: 1005, createdByUserID: 11,
               assignedTechID: nil, issueType: .hardware, priority: .medium,
               status: .open, descriptionText: "Screen unresponsive to touch",
               slaDueAt: Date.now.addingTimeInterval(5 * 3600 + 20 * 60),
               createdAt: Date.now.addingTimeInterval(-1 * 3600)),
        Ticket(ticketID: "STU044", atmID: 1006, createdByUserID: 12,
               assignedTechID: 240230, issueType: .hardware, priority: .high,
               status: .open, descriptionText: "Card reader not accepting cards",
               slaDueAt: Date.now.addingTimeInterval(3 * 3600 + 10 * 60),
               createdAt: Date.now.addingTimeInterval(-1 * 3600)),
        Ticket(ticketID: "VWX039", atmID: 1003, createdByUserID: 9,
               assignedTechID: 240231, issueType: .software, priority: .medium,
               status: .resolved, descriptionText: "Receipt printer out of paper",
               slaDueAt: Date.now.addingTimeInterval(-1 * 3600),
               createdAt: Date.now.addingTimeInterval(-10 * 3600),
               completedAt: Date.now.addingTimeInterval(-30 * 60)),

        // MARK: Historical — May through Aug 2026

        // May (≈ 113–128 days ago)
        Ticket(ticketID: "MAY001", atmID: 1001, createdByUserID: 9,
               assignedTechID: 240230, issueType: .hardware, priority: .critical,
               status: .resolved, descriptionText: "Dispenser belt worn — no cash out",
               slaDueAt:    Date.now.addingTimeInterval(-128 * 86400 + 4 * 3600),
               createdAt:   Date.now.addingTimeInterval(-128 * 86400),
               completedAt: Date.now.addingTimeInterval(-128 * 86400 + 2 * 3600)),
        Ticket(ticketID: "MAY002", atmID: 1004, createdByUserID: 10,
               assignedTechID: 240231, issueType: .network, priority: .high,
               status: .resolved, descriptionText: "ATM offline — network unreachable",
               slaDueAt:    Date.now.addingTimeInterval(-121 * 86400 + 8 * 3600),
               createdAt:   Date.now.addingTimeInterval(-121 * 86400),
               completedAt: Date.now.addingTimeInterval(-121 * 86400 + 3 * 3600)),
        Ticket(ticketID: "MAY003", atmID: 1003, createdByUserID: 9,
               assignedTechID: 240232, issueType: .cash, priority: .high,
               status: .resolved, descriptionText: "Cash cassette jam — no dispensing",
               slaDueAt:    Date.now.addingTimeInterval(-113 * 86400 + 8 * 3600),
               createdAt:   Date.now.addingTimeInterval(-113 * 86400),
               completedAt: Date.now.addingTimeInterval(-113 * 86400 + 2 * 3600 + 30 * 60)),

        // June (≈ 77–99 days ago)
        Ticket(ticketID: "JUN001", atmID: 1005, createdByUserID: 11,
               assignedTechID: 240230, issueType: .hardware, priority: .medium,
               status: .resolved, descriptionText: "Card reader not reading chip cards",
               slaDueAt:    Date.now.addingTimeInterval(-99 * 86400 + 24 * 3600),
               createdAt:   Date.now.addingTimeInterval(-99 * 86400),
               completedAt: Date.now.addingTimeInterval(-99 * 86400 + 1 * 3600 + 30 * 60)),
        Ticket(ticketID: "JUN002", atmID: 1002, createdByUserID: 8,
               assignedTechID: 240233, issueType: .software, priority: .medium,
               status: .resolved, descriptionText: "Screen freezes during transaction",
               slaDueAt:    Date.now.addingTimeInterval(-92 * 86400 + 24 * 3600),
               createdAt:   Date.now.addingTimeInterval(-92 * 86400),
               completedAt: Date.now.addingTimeInterval(-92 * 86400 + 4 * 3600)),
        Ticket(ticketID: "JUN003", atmID: 1006, createdByUserID: 12,
               assignedTechID: 240235, issueType: .cash, priority: .critical,
               status: .resolved, descriptionText: "Cash jam — dispenser jammed mid-cycle",
               slaDueAt:    Date.now.addingTimeInterval(-84 * 86400 + 4 * 3600),
               createdAt:   Date.now.addingTimeInterval(-84 * 86400),
               completedAt: Date.now.addingTimeInterval(-84 * 86400 + 2 * 3600)),
        Ticket(ticketID: "JUN004", atmID: 1001, createdByUserID: 9,
               assignedTechID: 240230, issueType: .hardware, priority: .critical,
               status: .resolved, descriptionText: "Shutter mechanism stuck — no dispensing",
               slaDueAt:    Date.now.addingTimeInterval(-77 * 86400 + 4 * 3600),
               createdAt:   Date.now.addingTimeInterval(-77 * 86400),
               completedAt: Date.now.addingTimeInterval(-77 * 86400 + 5 * 3600)),

        // July (≈ 43–65 days ago)
        Ticket(ticketID: "JUL001", atmID: 1003, createdByUserID: 9,
               assignedTechID: 240231, issueType: .network, priority: .high,
               status: .resolved, descriptionText: "Network dropped — router reset needed",
               slaDueAt:    Date.now.addingTimeInterval(-65 * 86400 + 8 * 3600),
               createdAt:   Date.now.addingTimeInterval(-65 * 86400),
               completedAt: Date.now.addingTimeInterval(-65 * 86400 + 1 * 3600)),
        Ticket(ticketID: "JUL002", atmID: 1004, createdByUserID: 10,
               assignedTechID: 240234, issueType: .hardware, priority: .medium,
               status: .resolved, descriptionText: "Touchscreen unresponsive — recalibrated",
               slaDueAt:    Date.now.addingTimeInterval(-58 * 86400 + 24 * 3600),
               createdAt:   Date.now.addingTimeInterval(-58 * 86400),
               completedAt: Date.now.addingTimeInterval(-58 * 86400 + 3 * 3600)),
        Ticket(ticketID: "JUL003", atmID: 1002, createdByUserID: 8,
               assignedTechID: 240232, issueType: .cash, priority: .high,
               status: .resolved, descriptionText: "Low cash alert — cassette replenished",
               slaDueAt:    Date.now.addingTimeInterval(-50 * 86400 + 8 * 3600),
               createdAt:   Date.now.addingTimeInterval(-50 * 86400),
               completedAt: Date.now.addingTimeInterval(-50 * 86400 + 2 * 3600)),
        Ticket(ticketID: "JUL004", atmID: 1005, createdByUserID: 11,
               assignedTechID: 240235, issueType: .other, priority: .low,
               status: .closed, descriptionText: "Quarterly preventive maintenance",
               slaDueAt:    Date.now.addingTimeInterval(-43 * 86400 + 48 * 3600),
               createdAt:   Date.now.addingTimeInterval(-43 * 86400),
               completedAt: Date.now.addingTimeInterval(-43 * 86400 + 1 * 3600 + 30 * 60)),

        // August (≈ 15–36 days ago)
        Ticket(ticketID: "AUG001", atmID: 1001, createdByUserID: 9,
               assignedTechID: 240230, issueType: .hardware, priority: .high,
               status: .resolved, descriptionText: "Card reader DIP module replaced",
               slaDueAt:    Date.now.addingTimeInterval(-36 * 86400 + 8 * 3600),
               createdAt:   Date.now.addingTimeInterval(-36 * 86400),
               completedAt: Date.now.addingTimeInterval(-36 * 86400 + 2 * 3600)),
        Ticket(ticketID: "AUG002", atmID: 1006, createdByUserID: 12,
               assignedTechID: 240233, issueType: .network, priority: .critical,
               status: .resolved, descriptionText: "ATM offline after power cycle — fiber reconnected",
               slaDueAt:    Date.now.addingTimeInterval(-29 * 86400 + 4 * 3600),
               createdAt:   Date.now.addingTimeInterval(-29 * 86400),
               completedAt: Date.now.addingTimeInterval(-29 * 86400 + 1 * 3600)),
        Ticket(ticketID: "AUG003", atmID: 1003, createdByUserID: 9,
               assignedTechID: 240231, issueType: .cash, priority: .high,
               status: .resolved, descriptionText: "Dispenser error E02 — pick module replaced",
               slaDueAt:    Date.now.addingTimeInterval(-22 * 86400 + 8 * 3600),
               createdAt:   Date.now.addingTimeInterval(-22 * 86400),
               completedAt: Date.now.addingTimeInterval(-22 * 86400 + 3 * 3600)),
        Ticket(ticketID: "AUG004", atmID: 1004, createdByUserID: 10,
               assignedTechID: 240230, issueType: .hardware, priority: .medium,
               status: .resolved, descriptionText: "EPP keypad unresponsive — unit swapped",
               slaDueAt:    Date.now.addingTimeInterval(-15 * 86400 + 24 * 3600),
               createdAt:   Date.now.addingTimeInterval(-15 * 86400),
               completedAt: Date.now.addingTimeInterval(-15 * 86400 + 2 * 3600 + 30 * 60))
    ]

    // MARK: - Van Inventory

    static let vanInventory: [Part] = [
        // Dispenser
        Part(id: 1, name: "Cassette 2 belt kit",  partNumber: "PN-440-013", category: .dispenser,  quantity: 2, minimumQuantity: 1),
        Part(id: 2, name: "Pick module",           partNumber: "PN-440-032", category: .dispenser,  quantity: 1, minimumQuantity: 2),
        Part(id: 3, name: "Shutter assembly",      partNumber: "PN-440-088", category: .dispenser,  quantity: 2, minimumQuantity: 1),

        // Card Reader & Keypad
        Part(id: 4, name: "Card reader DIP",       partNumber: "PN-350-112", category: .cardReader, quantity: 2, minimumQuantity: 2),
        Part(id: 5, name: "EPP keypad",            partNumber: "PN-350-215", category: .cardReader, quantity: 0, minimumQuantity: 1),
        Part(id: 6, name: "Card reader cleaning kit", partNumber: "PN-350-099", category: .cardReader, quantity: 3, minimumQuantity: 1),

        // Consumables
        Part(id: 7, name: "Receipt paper roll",    partNumber: "PN-009-054", category: .consumable, quantity: 9, minimumQuantity: 5),
        Part(id: 8, name: "ENA cleaning kit",      partNumber: "PN-009-120", category: .consumable, quantity: 1, minimumQuantity: 2),
        Part(id: 9, name: "Deposit envelope pack", partNumber: "PN-009-231", category: .consumable, quantity: 4, minimumQuantity: 2)
    ]

    // MARK: - Lookup Helpers

    static func atm(for ticket: Ticket) -> ATM? {
        atms.first { $0.id == ticket.atmID }
    }

    static func branch(for atm: ATM) -> Branch? {
        branches.first { $0.id == atm.branchID }
    }

    static func branch(for ticket: Ticket) -> Branch? {
        guard let atm = atm(for: ticket) else { return nil }
        return branch(for: atm)
    }

    static func technician(id: Int) -> Technician? {
        technicians.first { $0.id == id }
    }

    // MARK: - ATM Prior Visit Counts (static history stub)

    private static let atmPriorVisits: [Int: Int] = [
        1001: 2,
        1002: 0,
        1003: 1,
        1004: 4,
        1005: 1,
        1006: 0
    ]

    static func priorVisitCount(for atmID: Int) -> Int {
        atmPriorVisits[atmID] ?? 0
    }

    // MARK: - User name lookup

    private static let userNames: [Int: String] = [
        8: "Lisa P.", 9: "Marcus K.", 10: "Sarah T.", 11: "Jordan W.", 12: "David R."
    ]

    static func userName(for userID: Int) -> String {
        userNames[userID] ?? "User #\(userID)"
    }

    // MARK: - ATM History

    static let atmHistoryEntries: [ATMHistoryEntry] = [
        // ATM 1001 — Lakeland Main, Drive-up
        ATMHistoryEntry(id: 1,  atmID: 1001, dateLabel: "Aug 12", summary: "Dispenser jam — resolved",   techNote: "J. Torres · Replaced cassette 2, tested 10 cycles", isWarning: false),
        ATMHistoryEntry(id: 2,  atmID: 1001, dateLabel: "Jul 03", summary: "Dispenser jam — resolved",   techNote: "D. McLean · Replaced pick module",                    isWarning: false),
        ATMHistoryEntry(id: 3,  atmID: 1001, dateLabel: "Jun 18", summary: "Routine maintenance",        techNote: "J. Torres · Full inspection, no issues",              isWarning: false),
        ATMHistoryEntry(id: 4,  atmID: 1001, dateLabel: "⚠︎",     summary: "Third dispenser jam in 30 days", techNote: nil,                                               isWarning: true),

        // ATM 1002 — Lakeland Main, Lobby
        ATMHistoryEntry(id: 5,  atmID: 1002, dateLabel: "Aug 20", summary: "Card reader cleaned",        techNote: "M. Price · Routine cleaning",                         isWarning: false),
        ATMHistoryEntry(id: 6,  atmID: 1002, dateLabel: "Jul 15", summary: "Firmware update",            techNote: "A. Lewis · Updated to v4.2.1",                        isWarning: false),

        // ATM 1003 — Lakeland Main, Drive-up
        ATMHistoryEntry(id: 7,  atmID: 1003, dateLabel: "Sep 01", summary: "Paper refill — resolved",    techNote: "J. Torres · Replaced paper roll",                     isWarning: false),
        ATMHistoryEntry(id: 8,  atmID: 1003, dateLabel: "Aug 05", summary: "Routine maintenance",        techNote: "D. McLean · No issues found",                         isWarning: false),

        // ATM 1004 — Lake Nona, Drive-up
        ATMHistoryEntry(id: 9,  atmID: 1004, dateLabel: "Aug 28", summary: "Network reset",              techNote: "M. Price · Reconnected fiber",                        isWarning: false),
        ATMHistoryEntry(id: 10, atmID: 1004, dateLabel: "Aug 10", summary: "Network outage — resolved",  techNote: "A. Lewis · ISP issue resolved",                       isWarning: false),
        ATMHistoryEntry(id: 11, atmID: 1004, dateLabel: "⚠︎",     summary: "Second network issue in 30 days", techNote: nil,                                              isWarning: true),

        // ATM 1005 — Winter Park, Lobby
        ATMHistoryEntry(id: 12, atmID: 1005, dateLabel: "Sep 05", summary: "Screen calibrated",          techNote: "C. Brooks · Touchscreen recalibrated",                isWarning: false),

        // ATM 1006 — Waterford Lakes, Lobby
        ATMHistoryEntry(id: 13, atmID: 1006, dateLabel: "Aug 22", summary: "Card reader replaced",       techNote: "D. McLean · Unit swapped",                            isWarning: false),
        ATMHistoryEntry(id: 14, atmID: 1006, dateLabel: "Jul 30", summary: "Routine maintenance",        techNote: "M. Price · All clear",                                isWarning: false)
    ]

    static func history(for atmID: Int) -> [ATMHistoryEntry] {
        atmHistoryEntries.filter { $0.atmID == atmID }
    }

    // MARK: - Report Stats

    static func resolvedTickets(from tickets: [Ticket]) -> [Ticket] {
        tickets.filter { $0.status == .resolved || $0.status == .closed }
    }

    static func slaMetRate(for tickets: [Ticket]) -> Double {
        let resolved = resolvedTickets(from: tickets)
        guard !resolved.isEmpty else { return 0 }
        return Double(resolved.filter { $0.isSLAMet }.count) / Double(resolved.count)
    }

    static func avgResolutionInterval(for tickets: [Ticket]) -> TimeInterval {
        let resolved = resolvedTickets(from: tickets).filter { $0.completedAt != nil }
        guard !resolved.isEmpty else { return 0 }
        let total = resolved.reduce(0.0) { $0 + $1.completedAt!.timeIntervalSince($1.createdAt) }
        return total / Double(resolved.count)
    }

    static func slaRateByMonth(for tickets: [Ticket]) -> [(month: String, rate: Double)] {
        let resolved = resolvedTickets(from: tickets)
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        var grouped: [Date: [Ticket]] = [:]
        for ticket in resolved {
            let comps = calendar.dateComponents([.year, .month], from: ticket.createdAt)
            if let start = calendar.date(from: comps) {
                grouped[start, default: []].append(ticket)
            }
        }
        return grouped.sorted { $0.key < $1.key }.map { date, ts in
            let rate = ts.isEmpty ? 0 : Double(ts.filter { $0.isSLAMet }.count) / Double(ts.count)
            return (month: formatter.string(from: date), rate: rate)
        }
    }

    static func ticketsByIssueType(for tickets: [Ticket]) -> [(type: IssueType, count: Int)] {
        let resolved = resolvedTickets(from: tickets)
        var counts: [IssueType: Int] = [:]
        for ticket in resolved { counts[ticket.issueType, default: 0] += 1 }
        return IssueType.allCases.compactMap { type in
            guard let count = counts[type], count > 0 else { return nil }
            return (type: type, count: count)
        }.sorted { $0.count > $1.count }
    }
}
