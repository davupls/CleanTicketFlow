//
//  ProfileViewModel.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import Foundation

// MARK: - Row model

struct ProfileRow {
    let label: String
    let value: String
}

// MARK: - Base class

class ProfileViewModel {
    let initials: String
    let name: String
    let role: String
    let subtitle: String
    let employeeID: String
    let appVersion: String = "1.0.0"

    var accountRows: [ProfileRow] { [] }

    init(initials: String, name: String, role: String, subtitle: String, employeeID: String) {
        self.initials = initials
        self.name = name
        self.role = role
        self.subtitle = subtitle
        self.employeeID = employeeID
    }
}

// MARK: - Technician

class TechnicianProfileViewModel: ProfileViewModel {
    private let technician: Technician

    init(technician: Technician) {
        self.technician = technician
        super.init(
            initials: technician.initials,
            name: technician.name,
            role: "Technician",
            subtitle: "Field Technician · Zone \(technician.zone)",
            employeeID: "#\(technician.id)"
        )
    }

    override var accountRows: [ProfileRow] {
        [
            ProfileRow(label: "Email",       value: technician.user.email),
            ProfileRow(label: "Employee ID", value: employeeID),
            ProfileRow(label: "Zone",        value: "Zone \(technician.zone)"),
            ProfileRow(label: "Status",      value: technician.availability.label)
        ]
    }
}

// MARK: - Dispatcher

class DispatcherProfileViewModel: ProfileViewModel {
    init() {
        super.init(
            initials: "SD",
            name: "Sarah D.",
            role: "Dispatcher",
            subtitle: "Dispatcher",
            employeeID: "#042"
        )
    }

    override var accountRows: [ProfileRow] {
        [
            ProfileRow(label: "Email",       value: "dispatcher@test.com"),
            ProfileRow(label: "Region",      value: "Central Florida"),
            ProfileRow(label: "Employee ID", value: employeeID)
        ]
    }
}

// MARK: - Custodian

class CustodianProfileViewModel: ProfileViewModel {
    init() {
        super.init(
            initials: "MK",
            name: "Marcus K.",
            role: "Custodian",
            subtitle: "Branch Custodian",
            employeeID: "#009"
        )
    }

    override var accountRows: [ProfileRow] {
        [
            ProfileRow(label: "Email",       value: "test@test.com"),
            ProfileRow(label: "Branch",      value: "Lakeland Main Branch"),
            ProfileRow(label: "Employee ID", value: employeeID)
        ]
    }
}
