//
//  TicketListView.swift.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/5/26.
//

import SwiftUI

struct TicketListView: View {
    
    @State var tickets = SampleData.tickets
    
    
    var body: some View {
        
        //      Encapsulate TicketsList later
        ScrollView {
            
            VStack(spacing: 10) {
                ForEach(tickets) { ticket in
                    NavigationLink(destination: TicketDetailView(ticket: ticket)) {
                        TicketRowView(ticket: ticket)
                    }
                    .buttonStyle(.plain)
                }
            }
            
        }
    }
}

#Preview {
    TicketListView()
}


