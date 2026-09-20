//
//  AssignTechSheet.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/9/26.
//

import SwiftUI
import SwiftData

struct AssignTechSheet: View {
    let ticket: Ticket
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allTickets: [Ticket]

    @State private var selectedTechID: Int? = nil
    @State private var showOnJob = false
    @State private var showOffShift = false

    private var ticketZone: Int { ticket.atm?.zone ?? 0 }

    private var sortedTechs: [Technician] {
        SampleData.technicians.sorted {
            abs($0.zone - ticketZone) < abs($1.zone - ticketZone)
        }
    }

    private var availableTechs: [Technician] {
        sortedTechs.filter { $0.availability == .available }
    }

    private var onJobTechs: [Technician] {
        sortedTechs.filter { $0.availability == .onSite || $0.availability == .enRoute }
    }

    private var offShiftTechs: [Technician] {
        sortedTechs.filter { $0.availability == .offShift }
    }

    private var selectedTech: Technician? {
        guard let id = selectedTechID else { return nil }
        return SampleData.technician(id: id)
    }

    private func openTicketCount(for tech: Technician) -> Int {
        allTickets.filter {
            $0.assignedTechID == tech.id &&
            $0.status != .resolved &&
            $0.status != .closed
        }.count
    }

    var body: some View {
        NavigationStack {
            List {
                contextSection

                if !availableTechs.isEmpty {
                    Section("Available · \(availableTechs.count)") {
                        ForEach(availableTechs) { tech in
                            techRow(tech)
                        }
                    }
                }

                if !onJobTechs.isEmpty {
                    Section {
                        if showOnJob {
                            ForEach(onJobTechs) { tech in
                                techRow(tech)
                            }
                        }
                    } header: {
                        collapsibleHeader("On a job · \(onJobTechs.count)", isExpanded: $showOnJob)
                    }
                }

                if !offShiftTechs.isEmpty {
                    Section {
                        if showOffShift {
                            ForEach(offShiftTechs) { tech in
                                techRow(tech)
                            }
                        }
                    } header: {
                        collapsibleHeader("Off shift · \(offShiftTechs.count)", isExpanded: $showOffShift)
                    }
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("Assign technician")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let tech = selectedTech {
                    VStack(spacing: 0) {
                        Divider()
                        Button {
                            ticket.assignedTechID = tech.id
                            dismiss()
                        } label: {
                            Text("Assign to \(tech.name)")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding()
                    }
                    .background(Color(.systemBackground))
                }
            }
        }
    }

    // MARK: - Context Section

    private var contextSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text("#\(ticket.ticketID) · ATM-\(ticket.atmID)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(ticket.descriptionText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                if !ticket.locationSummary.isEmpty {
                    Text(ticket.locationSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(slaContextNote)
                    .font(.caption)
                    .foregroundStyle(slaContextColor)
                    .padding(.top, 2)
            }
            .padding(.vertical, 2)
        }
    }

    private var slaContextNote: String {
        let r = ticket.slaRemaining
        let total = abs(r)
        let h = Int(total) / 3600
        let m = (Int(total) % 3600) / 60
        let timeString = h > 0 ? "\(h)h \(m)m" : "\(m)m"
        return r <= 0
            ? "SLA exceeded by \(timeString). Assign immediately."
            : "SLA \(timeString) left. Techs sorted by zone proximity."
    }

    private var slaContextColor: Color {
        let r = ticket.slaRemaining
        if r <= 0       { return .red }
        if r < 2 * 3600 { return .red }
        if r < 4 * 3600 { return .orange }
        return .secondary
    }

    // MARK: - Tech Row

    private func techRow(_ tech: Technician) -> some View {
        let openCount = openTicketCount(for: tech)
        let isSelected = selectedTechID == tech.id
        return Button {
            selectedTechID = isSelected ? nil : tech.id
        } label: {
            HStack(spacing: 12) {
                TechInitialsCircle(initials: tech.initials, size: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(tech.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text("Zone \(tech.zone) · \(openCount) open ticket\(openCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                        .font(.title3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(isSelected ? Color.accentColor.opacity(0.07) : nil)
    }

    // MARK: - Collapsible Header

    private func collapsibleHeader(_ title: String, isExpanded: Binding<Bool>) -> some View {
        HStack {
            Text(title)
            Spacer()
            Button(isExpanded.wrappedValue ? "Hide" : "Show") {
                isExpanded.wrappedValue.toggle()
            }
            .font(.caption)
            .foregroundStyle(Color.accentColor)
            .textCase(nil)
        }
    }
}

#Preview {
    AssignTechSheet(ticket: SampleData.tickets[3])
        .modelContainer(for: Ticket.self, inMemory: true)
}
