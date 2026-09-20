//
//  CustodianProfileView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import SwiftUI

struct CustodianProfileView: View {
    var body: some View {
        ProfileView(viewModel: CustodianProfileViewModel())
    }
}

#Preview {
    NavigationStack {
        CustodianProfileView()
    }
}
