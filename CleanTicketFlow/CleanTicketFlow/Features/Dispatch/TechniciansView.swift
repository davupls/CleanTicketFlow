//
//  TechniciansView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/9/26.
//

import SwiftUI
import SwiftData

private enum TechFilter: String, CaseIterable {
    case all = "All"
    case available = "Available"
    case onJob = "On a job"
    case off = "Off"
}

struct TechniciansView: View {
    @Query private var tickets: [Ticket]
    @State private var filter: TechFilter = .all

    private var onShiftCount: Int {
        SampleData.technicians.filter { $0.availability != .offShift }.count
    }

    private var offShiftCount: Int {
        SampleData.technicians.filter { $0.availability == .offShift }.count
    }

    private var filteredTechs: [Technician] {
        switch filter {
        case .all:
            return SampleData.technicians
        case .available:
            return SampleData.technicians.filter { $0.availability == .available }
        case .onJob:
            return SampleData.technicians.filter { $0.availability == .onSite || $0.availability == .enRoute }
        case .off:
            return SampleData.technicians.filter { $0.availability == .offShift }
        }
    }

    var body: some View {
        List {
            filterSection
            techsSection
            weekStatsSection
        }
        .listSectionSpacing(.compact)
        .navigationTitle("Technicians")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(onShiftCount) on shift · \(offShiftCount) off")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TechFilter.allCases, id: \.self) { f in
                        Button {
                            filter = f
                        } label: {
                            Text(f.rawValue)
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

    // MARK: - Techs Section

    private var techsSection: some View {
        Section {
            ForEach(filteredTechs) { tech in
                TechListRow(tech: tech, tickets: tickets)
            }
        }
    }

    // MARK: - Week Stats Section

    private var weekStatsSection: some View {
        Section("This week") {
            HStack(spacing: 10) {
                WeekStatCard(title: "Tickets closed", value: "\(closedThisWeek)", color: .blue)
                WeekStatCard(title: "SLA met", value: slaMetString, color: .green)
                WeekStatCard(title: "Avg resolve", value: avgResolveString, color: .purple)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
        }
    }

    // MARK: - Stats Computations

    private var resolvedThisWeek: [Ticket] {
        let weekAgo = Date.now.addingTimeInterval(-7 * 24 * 3600)
        return tickets.filter {
            guard let c = $0.completedAt else { return false }
            return c >= weekAgo
        }
    }

    private var closedThisWeek: Int { resolvedThisWeek.count }

    private var slaMetString: String {
        guard !resolvedThisWeek.isEmpty else { return "--" }
        let met = resolvedThisWeek.filter { $0.isSLAMet }.count
        return "\(Int(Double(met) / Double(resolvedThisWeek.count) * 100))%"
    }

    private var avgResolveString: String {
        guard !resolvedThisWeek.isEmpty else { return "--" }
        let total = resolvedThisWeek.reduce(0.0) { sum, t in
            guard let c = t.completedAt else { return sum }
            return sum + c.timeIntervalSince(t.createdAt)
        }
        let avg = Int(total / Double(resolvedThisWeek.count))
        let h = avg / 3600
        let m = (avg % 3600) / 60
        return "\(h)h \(m)m"
    }
}

// MARK: - Tech List Row

private struct TechListRow: View {
    let tech: Technician
    let tickets: [Ticket]

    private var activeTicket: Ticket? {
        tickets.first {
            $0.assignedTechID == tech.id &&
            ($0.status == .enRoute || $0.status == .onSite || $0.status == .open)
        }
    }

    private var assignedTodayCount: Int {
        tickets.filter {
            $0.assignedTechID == tech.id &&
            Calendar.current.isDateInToday($0.createdAt)
        }.count
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                TechInitialsCircle(initials: tech.initials, size: 44)
                Circle()
                    .fill(availabilityColor)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(tech.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(statusLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            rightBadge
        }
        .padding(.vertical, 2)
    }

    private var statusLine: String {
        switch tech.availability {
        case .onSite:
            if let t = activeTicket {
                return "On site · #\(t.ticketID) · \(assignedTodayCount) assigned today"
            }
            return "On site · \(assignedTodayCount) assigned today"
        case .enRoute:
            if let t = activeTicket {
                return "En route to #\(t.ticketID) · \(assignedTodayCount) assigned today"
            }
            return "En route · \(assignedTodayCount) assigned today"
        case .available:
            return "Zone \(tech.zone) · Available · \(assignedTodayCount) assigned today"
        case .offShift:
            return "Off shift"
        }
    }

    @ViewBuilder
    private var rightBadge: some View {
        switch tech.availability {
        case .available:
            Text("Free")
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.green.opacity(0.15))
                .foregroundStyle(.green)
                .clipShape(Capsule())
        case .onSite, .enRoute:
            if let t = activeTicket {
                Text(slaLabel(for: t))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(slaColor(for: t).opacity(0.15))
                    .foregroundStyle(slaColor(for: t))
                    .clipShape(Capsule())
            }
        case .offShift:
            EmptyView()
        }
    }

    private func slaLabel(for ticket: Ticket) -> String {
        let r = ticket.slaRemaining
        if r <= 0 { return "SLA past" }
        let h = Int(r) / 3600
        let m = (Int(r) % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m left"
    }

    private func slaColor(for ticket: Ticket) -> Color {
        let r = ticket.slaRemaining
        if r <= 0       { return .red }
        if r < 2 * 3600 { return .red }
        if r < 4 * 3600 { return .orange }
        return .green
    }

    private var availabilityColor: Color {
        switch tech.availability {
        case .available: return .green
        case .onSite:    return .orange
        case .enRoute:   return .blue
        case .offShift:  return .gray
        }
    }
}

// MARK: - Week Stat Card

private struct WeekStatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
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

#Preview {
    NavigationStack {
        TechniciansView()
    }
    .modelContainer(for: Ticket.self, inMemory: true)
}
