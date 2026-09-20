//
//  TicketsStatusBubbles.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/4/26.
//

import SwiftUI

struct TicketsStatusBubbles: View {
    var body: some View {


        ScrollView(.horizontal) {

            HStack {
                //    Encapsulate later into a single view
                Text("Assigned: 3")
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 20.0))
                
                Text("In progress: 1")
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 20.0))
                
                Text("Completed: 2")
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 20.0))
            }
            
        }

            
    }
}

#Preview {
    TicketsStatusBubbles()
}
