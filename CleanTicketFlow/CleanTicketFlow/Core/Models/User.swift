//
//  User.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/5/26.
//

import Foundation
// This model is be the base for all user type: Custodian, Technician and Dispatch

struct User {
    let id: Int
    var name: String
    var email: String
    var phone: String?
    var userRole: String
    var password: String
}
