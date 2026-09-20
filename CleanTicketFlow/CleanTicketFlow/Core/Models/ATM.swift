//
//  ATM.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/5/26.
//

import Foundation

struct ATM: Identifiable {
    let id: Int
    let branchID: Int
    let zone: Int
    let model: String
    let location: String
    let installedYear: Int
}
