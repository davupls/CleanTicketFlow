//
//  DashboardHeader.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/4/26.
//

import SwiftUI

struct DashboardHeader: View {

//  This View will encapsulate the header suction of the Tickets View.
    var body: some View {
        
        HStack {
            VStack(alignment: .leading) {
                Text("My Tickets")
                Text("David M.")
            }
            
            
            Spacer()
            
            Image(systemName: "bell")
        }
        .padding(.horizontal)
        
    }
    
}

#Preview {
    DashboardHeader()
}
