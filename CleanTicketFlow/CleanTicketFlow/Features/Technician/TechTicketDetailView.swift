//
//  TechTicketDetailView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import SwiftUI
import SwiftData

struct TechTicketDetailView: View {
    let ticket: Ticket
    let technician: Technician

    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    @State private var showAllHistory = false
    @State private var showAddNoteSheet = false
    @State private var showAddPartSheet = false
    @State private var showResolveSheet = false
    @State private var usedParts: [Part] = []
    @State private var noteText = ""

    var body: some View {
        List {
            headerSection
            atmInfoSection
            historySection
            partsSection
        }
        .listSectionSpacing(.compact)
        .navigationTitle("#\(ticket.ticketID)")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            footerButtons
        }
        .sheet(isPresented: $showAddNoteSheet) {
            AddNoteSheet(noteText: $noteText)
        }
        .sheet(isPresented: $showAddPartSheet) {
            AddPartSheet(usedParts: $usedParts)
        }
        .sheet(isPresented: $showResolveSheet) {
            ResolveSheet(noteText: $noteText) {
                ticket.status = .resolved
                ticket.completedAt = .now
                dismiss()
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                statusBadge

                Text(ticket.descriptionText)
                    .font(.title3)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Reported by \(SampleData.userName(for: ticket.createdByUserID))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(ticket.createdAt.formatted(date: .abbreviated, time: .shortened)) · Priority: \(ticket.priority.rawValue.lowercased())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var statusBadge: some View {
        let (label, color) = statusInfo
        return Text(label)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var statusInfo: (String, Color) {
        switch ticket.status {
        case .open:       return ("Assigned", .purple)
        case .enRoute:    return ("En Route", .blue)
        case .onSite:    return ("On Site", .orange)
        case .resolved:  return ("Resolved", .green)
        case .closed:     return ("Closed", .gray)
        case .cancelled:  return ("Cancelled", .red)
        }
    }

    private var nextStatusAction: (status: TicketStatus, label: String, color: Color)? {
        switch ticket.status {
        case .open:                return (.enRoute,  "En Route",      .blue)
        case .enRoute:             return (.onSite,   "On Site",       .orange)
        case .onSite:              return (.resolved, "Mark Resolved", .green)
        default:                   return nil
        }
    }

    // MARK: - ATM Info Section

    private var atmInfoSection: some View {
        Section("ATM Info") {
            if let atm = ticket.atm, let branch = ticket.branch {
                VStack(alignment: .leading, spacing: 6) {
                    Label("ATM-\(atm.id) · \(atm.location)", systemImage: "banknote")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("\(branch.name) · \(branch.address)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(branch.city), \(branch.state) \(branch.zip)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(atm.model) · Installed \(atm.installedYear)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button {
                        let address = "\(branch.address), \(branch.city), \(branch.state) \(branch.zip)"
                        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "maps://?q=\(encoded)") {
                            openURL(url)
                        }
                    } label: {
                        Label("Directions", systemImage: "arrow.triangle.turn.up.right.circle")
                    }
                    .font(.subheadline)
                    .padding(.top, 2)
                }
                .padding(.vertical, 4)
            } else {
                Text("ATM information unavailable")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - History Section

    private var historySection: some View {
        let entries = SampleData.history(for: ticket.atmID)
        let displayed = showAllHistory ? entries : Array(entries.prefix(2))

        return Section {
            ForEach(displayed) { entry in
                historyRow(entry)
            }
            if entries.count > 2 {
                Button(showAllHistory ? "Show less" : "All \(entries.count)") {
                    showAllHistory.toggle()
                }
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)
            }
        } header: {
            Text("ATM History")
        }
    }

    private func historyRow(_ entry: ATMHistoryEntry) -> some View {
        HStack(alignment: .top, spacing: 10) {
            if entry.isWarning {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .frame(width: 28)
            } else {
                Text(entry.dateLabel)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.summary)
                    .font(.subheadline)
                    .fontWeight(entry.isWarning ? .semibold : .regular)
                    .foregroundStyle(entry.isWarning ? .orange : .primary)

                if let note = entry.techNote {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Parts Section

    private var partsSection: some View {
        Section {
            Button {
                showAddPartSheet = true
            } label: {
                Label("Add from van", systemImage: "plus.circle")
            }
            .foregroundStyle(Color.accentColor)

            ForEach(usedParts) { part in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(part.name)
                            .font(.subheadline)
                        Text(part.partNumber)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("+1 used")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Parts used on this ticket")
        }
    }

    // MARK: - Footer

    @ViewBuilder
    private var footerButtons: some View {
        if let next = nextStatusAction {
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    Button {
                        showAddNoteSheet = true
                    } label: {
                        Text("Add note")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    Button {
                        if next.status == .resolved {
                            showResolveSheet = true
                        } else {
                            ticket.status = next.status
                        }
                    } label: {
                        Text(next.label)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(next.color)
                    .controlSize(.large)
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Add Note Sheet

private struct AddNoteSheet: View {
    @Binding var noteText: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            TextEditor(text: $noteText)
                .padding()
                .navigationTitle("Add Note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") { dismiss() }
                            .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
        }
    }
}

// MARK: - Add Part Sheet

private struct AddPartSheet: View {
    @Binding var usedParts: [Part]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(PartCategory.allCases, id: \.self) { category in
                    let parts = SampleData.vanInventory.filter { $0.category == category }
                    if !parts.isEmpty {
                        Section(category.rawValue) {
                            ForEach(parts) { part in
                                Button {
                                    usedParts.append(part)
                                    dismiss()
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(part.name)
                                                .foregroundStyle(.primary)
                                            Text(part.partNumber)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text("Qty: \(part.quantity)")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundStyle(part.isBelowMinimum ? .orange : .secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("Add from Van")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Resolve Sheet

private struct ResolveSheet: View {
    @Binding var noteText: String
    let onResolve: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Describe what was done to resolve this ticket.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding([.horizontal, .top])
                    .padding(.bottom, 8)
                TextEditor(text: $noteText)
                    .padding(.horizontal, 8)
            }
            .navigationTitle("Resolution Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save & Resolve") {
                        onResolve()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TechTicketDetailView(
            ticket: SampleData.tickets[0],
            technician: SampleData.technicians[0]
        )
    }
    .modelContainer(for: Ticket.self, inMemory: true)
}
