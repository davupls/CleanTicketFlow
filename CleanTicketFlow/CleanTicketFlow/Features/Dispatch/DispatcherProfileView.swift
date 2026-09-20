//
//  DispatcherProfileView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import SwiftUI

struct DispatcherProfileView: View {
    var body: some View {
        ProfileView(viewModel: DispatcherProfileViewModel())
    }
}

#Preview {
    NavigationStack {
        DispatcherProfileView()
    }
}
