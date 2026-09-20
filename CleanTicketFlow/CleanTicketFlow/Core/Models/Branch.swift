//
//  Branch.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/5/26.
//

import Foundation

struct Branch: Identifiable {
    let id: Int
    
    let name: String
    let address: String
    let city: String
    let state: String
    let zip: String
    let phone: String?
    
}
