//
//  VanInventoryDashboard.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/5/26.
//

import SwiftUI

struct VanInventoryDashboard: View {
    let parts: [Part]
    @State private var searchText = ""

    // MARK: - Filtered collections

    private var filteredParts: [Part] {
        guard !searchText.isEmpty else { return parts }
        return parts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.partNumber.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func categoryParts(for category: PartCategory) -> [Part] {
        filteredParts.filter { $0.category == category }
    }

    // Uses the full (unfiltered) list so the restock count is always accurate
    private var belowMinimumParts: [Part] {
        parts.filter(\.isBelowMinimum)
    }

    // Respects search when showing the warning section
    private var filteredBelowMinimum: [Part] {
        filteredParts.filter(\.isBelowMinimum)
    }

    // MARK: - Body

    var body: some View {
        List {
            if !filteredBelowMinimum.isEmpty {
                belowMinimumSection
            }

            ForEach(PartCategory.allCases, id: \.self) { category in
                let items = categoryParts(for: category)
                if !items.isEmpty {
                    Section(category.rawValue) {
                        ForEach(items) { part in
                            PartRow(part: part)
                        }
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .searchable(text: $searchText, prompt: "Part name or PN")
        .navigationTitle("Van Inventory")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Van 1 · \(parts.count) SKUs")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !belowMinimumParts.isEmpty {
                restockButton
            }
        }
    }

    // MARK: - Below Minimum Section

    private var belowMinimumSection: some View {
        Section {
            ForEach(filteredBelowMinimum) { part in
                PartRow(part: part)
            }
        } header: {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Below minimum")
            }
        }
    }

    // MARK: - Restock Button

    private var restockButton: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                // TODO: submit restock request to dispatcher
            } label: {
                let count = belowMinimumParts.count
                Text("Request restock (\(count) item\(count == 1 ? "" : "s"))")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .controlSize(.large)
            .padding()
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Part Row

private struct PartRow: View {
    let part: Part

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(part.name)
                    .font(.subheadline)
                Text(part.partNumber)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(part.quantity)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(part.isBelowMinimum ? .orange : .primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    part.isBelowMinimum ? Color.orange.opacity(0.12) : Color(.systemGray5)
                )
                .clipShape(Capsule())
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        VanInventoryDashboard(parts: SampleData.vanInventory)
    }
}
