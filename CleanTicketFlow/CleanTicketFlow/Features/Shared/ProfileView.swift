//
//  ProfileView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import SwiftUI

struct ProfileView: View {
    let viewModel: ProfileViewModel
    @Environment(\.signOut) private var signOut

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 60, height: 60)
                        Text(viewModel.initials)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.name)
                            .font(.headline)
                        Text(viewModel.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }

            Section("Account") {
                ForEach(viewModel.accountRows, id: \.label) { row in
                    LabeledContent(row.label, value: row.value)
                }
            }

            Section("App") {
                LabeledContent("Version", value: viewModel.appVersion)
                LabeledContent("Role", value: viewModel.role)
            }

            Section {
                Button(role: .destructive) {
                    signOut()
                } label: {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Profile")
    }
}
