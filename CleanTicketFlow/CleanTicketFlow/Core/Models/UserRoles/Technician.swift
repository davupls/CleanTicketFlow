//
//  Technician.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/6/26.
//

import Foundation

enum TechnicianAvailability {
    case available
    case onSite
    case enRoute
    case offShift

    var label: String {
        switch self {
        case .available: return "Available"
        case .onSite:    return "On site"
        case .enRoute:   return "En route"
        case .offShift:  return "Off shift"
        }
    }
}

struct Technician: Identifiable {
    let user: User
    let initials: String
    let zone: Int
    var availability: TechnicianAvailability

    var id: Int { user.id }
    var name: String { user.name }
}
