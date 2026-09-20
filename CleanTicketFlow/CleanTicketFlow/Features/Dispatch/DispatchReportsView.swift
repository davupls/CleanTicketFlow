//
//  DispatchReportsView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import SwiftUI
import UIKit

struct DispatchReportsView: View {
    private let allTickets = SampleData.tickets

    private var resolved: [Ticket]          { SampleData.resolvedTickets(from: allTickets) }
    private var slaRate: Double              { SampleData.slaMetRate(for: allTickets) }
    private var slaMetCount: Int             { resolved.filter { $0.isSLAMet }.count }
    private var avgResolution: TimeInterval  { SampleData.avgResolutionInterval(for: allTickets) }
    private var monthlyRates: [(month: String, rate: Double)]  { SampleData.slaRateByMonth(for: allTickets) }
    private var issueBreakdown: [(type: IssueType, count: Int)] { SampleData.ticketsByIssueType(for: allTickets) }

    private var slaRateLabel: String     { "\(Int(slaRate * 100))%" }
    private var slaFractionLabel: String { "\(slaMetCount) of \(resolved.count)" }
    private var avgResolutionLabel: String {
        let secs = Int(avgResolution)
        return "\(secs / 3600)h \((secs % 3600) / 60)m"
    }

    @State private var pdfFile: PDFFile? = nil

    var body: some View {
        List {
            statSection
            slaByMonthSection
            issueTypeSection
            partsSection
        }
        .listSectionSpacing(.compact)
        .navigationTitle("Reports")
        .safeAreaInset(edge: .bottom) {
            exportButton
        }
        .sheet(item: $pdfFile) { file in
            ActivityView(url: file.url)
        }
    }

    // MARK: - Stat Cards

    private var statSection: some View {
        Section {
            HStack(spacing: 12) {
                ReportStatCard(title: "SLA met",        value: slaRateLabel,       subtitle: slaFractionLabel)
                ReportStatCard(title: "Avg resolution", value: avgResolutionLabel, subtitle: "Target 4h")
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
    }

    // MARK: - SLA by Month

    private var slaByMonthSection: some View {
        Section("SLA met by month") {
            VStack(spacing: 10) {
                ForEach(monthlyRates.indices, id: \.self) { i in
                    MonthBarRow(month: monthlyRates[i].month, rate: monthlyRates[i].rate)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Issue Type Breakdown

    private var issueTypeSection: some View {
        Section("Tickets by issue type") {
            ForEach(issueBreakdown.indices, id: \.self) { i in
                HStack {
                    Text(issueBreakdown[i].type.rawValue)
                    Spacer()
                    Text("\(issueBreakdown[i].count)")
                        .foregroundStyle(.secondary)
                        .fontWeight(.medium)
                        .monospacedDigit()
                }
            }
        }
    }

    // MARK: - Parts Used

    private var partsSection: some View {
        Section("Parts") {
            HStack {
                Text("Parts used · 43 items").fontWeight(.medium)
                Spacer()
                Button("Full log") { }.font(.subheadline)
            }
            HStack { Text("Pick module");         Spacer(); Text("+12").foregroundStyle(.secondary).monospacedDigit() }
            HStack { Text("Card reader DIP");     Spacer(); Text("+8").foregroundStyle(.secondary).monospacedDigit() }
            HStack { Text("Cassette 2 belt kit"); Spacer(); Text("+6").foregroundStyle(.secondary).monospacedDigit() }
        }
    }

    // MARK: - Export Button

    private var exportButton: some View {
        Button {
            generatePDF()
        } label: {
            Label("SLA Report PDF", systemImage: "doc.text")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }

    // MARK: - PDF Generation

    @MainActor
    private func generatePDF() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short

        let reportView = SLAReportDocumentView(
            tickets: resolved,
            generatedDate: formatter.string(from: Date()),
            slaRate: slaRateLabel,
            avgResolution: avgResolutionLabel,
            totalClosed: resolved.count
        )
        .environment(\.colorScheme, .light)

        let renderer = ImageRenderer(content: reportView)
        renderer.scale = 2.0

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("SLA_Report.pdf")

        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: size)
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }

        pdfFile = PDFFile(url: url)
    }
}

// MARK: - PDF File (sheet item wrapper)

private struct PDFFile: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - Share Sheet

private struct ActivityView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - SLA Report Document (rendered to PDF)

private struct SLAReportDocumentView: View {
    let tickets: [Ticket]
    let generatedDate: String
    let slaRate: String
    let avgResolution: String
    let totalClosed: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 6) {
                Text("SLA Performance Report")
                    .font(.system(size: 26, weight: .bold))
                Text("Atomic ATM Services · Central Florida Region")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Text("Generated \(generatedDate)")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 20)

            Divider().padding(.bottom, 18)

            // Summary stats
            HStack(spacing: 40) {
                summaryStatView(label: "SLA Met Rate",    value: slaRate)
                summaryStatView(label: "Avg Resolution",  value: avgResolution)
                summaryStatView(label: "Total Closed",    value: "\(totalClosed)")
            }
            .padding(.bottom, 24)

            Divider().padding(.bottom, 14)

            // Table header
            tableHeader

            // Table rows
            ForEach(tickets) { ticket in
                tableRow(for: ticket)
                Divider()
            }

            Spacer(minLength: 40)

            Divider().padding(.top, 8)
            Text("CleanTicketFlow · Atomic ATM Services · Confidential")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .padding(.top, 6)
        }
        .padding(48)
        .frame(width: 700)
        .background(Color.white)
    }

    private func summaryStatView(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 22, weight: .bold))
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            Text("Ticket ID").frame(width: 90,  alignment: .leading)
            Text("ATM").frame(width: 75,  alignment: .leading)
            Text("Type").frame(width: 90,  alignment: .leading)
            Text("Priority").frame(width: 80,  alignment: .leading)
            Text("SLA Status").frame(width: 100, alignment: .leading)
            Text("Resolution").frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.system(size: 11, weight: .semibold))
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(Color(white: 0.90))
    }

    private func tableRow(for ticket: Ticket) -> some View {
        HStack(spacing: 0) {
            Text("#\(ticket.ticketID)").frame(width: 90,  alignment: .leading)
            Text("ATM-\(ticket.atmID)").frame(width: 75,  alignment: .leading)
            Text(ticket.issueType.rawValue).frame(width: 90,  alignment: .leading)
            Text(ticket.priority.rawValue).frame(width: 80,  alignment: .leading)
            Text(ticket.isSLAMet ? "Met ✓" : "Missed ✗")
                .foregroundStyle(ticket.isSLAMet ? .green : .red)
                .frame(width: 100, alignment: .leading)
            resolutionText(for: ticket)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.system(size: 11))
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
    }

    @ViewBuilder
    private func resolutionText(for ticket: Ticket) -> some View {
        if let completedAt = ticket.completedAt {
            let secs = Int(completedAt.timeIntervalSince(ticket.createdAt))
            Text("\(secs / 3600)h \((secs % 3600) / 60)m")
        } else {
            Text("—")
        }
    }
}

// MARK: - Stat Card

private struct ReportStatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title).fontWeight(.bold)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Month Bar Row

private struct MonthBarRow: View {
    let month: String
    let rate: Double

    var body: some View {
        HStack(spacing: 10) {
            Text(month)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5))
                    Capsule().fill(Color.accentColor)
                        .frame(width: geo.size.width * rate)
                }
            }
            .frame(height: 8)
            Text("\(Int(rate * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 38, alignment: .trailing)
                .monospacedDigit()
        }
    }
}

#Preview {
    NavigationStack {
        DispatchReportsView()
    }
}
