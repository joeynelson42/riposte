//
//  PawnAction.swift
//
//
//  Created by Joey Nelson on 5/31/24.
//

import Foundation

enum PawnAction {
    case move, attack, support, endTurn
    
    var title: String {
        switch self {
        case .move: "Move"
        case .attack: "Attack"
        case .support: "Support"
        case .endTurn: "End Turn"
        }
    }
    
    // Higher value == higher priority
    var displayPriority: Int {
        switch self {
        case .move: 0
        case .attack: 2
        case .support: 1
        case .endTurn: -1
        }
    }
}
