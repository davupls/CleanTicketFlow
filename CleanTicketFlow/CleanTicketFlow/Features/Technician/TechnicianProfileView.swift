//
//  TechnicianProfileView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import SwiftUI

struct TechnicianProfileView: View {
    let technician: Technician

    var body: some View {
        ProfileView(viewModel: TechnicianProfileViewModel(technician: technician))
    }
}

#Preview {
    NavigationStack {
        TechnicianProfileView(technician: SampleData.technicians[0])
    }
}
