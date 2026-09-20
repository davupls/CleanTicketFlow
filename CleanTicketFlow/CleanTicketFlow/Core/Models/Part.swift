//
//  Part.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import Foundation

enum PartCategory: String, CaseIterable {
    case dispenser    = "Dispenser"
    case cardReader   = "Card Reader & Keypad"
    case consumable   = "Consumables"
}

struct Part: Identifiable {
    let id: Int
    let name: String
    let partNumber: String
    let category: PartCategory
    var quantity: Int
    let minimumQuantity: Int

    var isBelowMinimum: Bool {
        quantity < minimumQuantity
    }
}
