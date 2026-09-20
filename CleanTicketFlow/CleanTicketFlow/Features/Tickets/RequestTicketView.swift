//
//  RequestTicket.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/5/26.
//

import SwiftUI
import SwiftData

struct RequestTicketView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedATMID: Int = SampleData.atms[0].id
    @State private var selectedIssueType: IssueType = .hardware
    @State private var selectedPriority: Priority = .medium
    @State private var descriptionText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("ATM") {
                    Picker("Select ATM", selection: $selectedATMID) {
                        ForEach(SampleData.atms) { atm in
                            Text("ATM-\(atm.id) • \(atm.location)").tag(atm.id)
                        }
                    }
                }

                Section("Issue Type") {
                    Picker("Issue Type", selection: $selectedIssueType) {
                        ForEach(IssueType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Priority") {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Issue Description") {
                    TextEditor(text: $descriptionText)
                        .frame(minHeight: 100)
                }

                Section {
                    Button("Submit Request") {
                        submitTicket()
                    }
                    .disabled(descriptionText.isEmpty)
                }
            }
            .navigationTitle("Report an Issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func submitTicket() {
        let ticketID = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(6)).uppercased()
        let ticket = Ticket(
            ticketID: ticketID,
            atmID: selectedATMID,
            createdByUserID: 1,
            issueType: selectedIssueType,
            priority: selectedPriority,
            status: .open,
            descriptionText: descriptionText,
            slaDueAt: Date.now.addingTimeInterval(4 * 3600)
        )
        modelContext.insert(ticket)
        dismiss()
    }
}

#Preview {
    RequestTicketView()
        .modelContainer(for: Ticket.self, inMemory: true)
}
