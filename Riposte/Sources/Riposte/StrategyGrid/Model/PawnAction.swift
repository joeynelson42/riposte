//
//  PawnAction.swift
//
//
//  Created by Joey Nelson on 5/31/24.
//

import Foundation

indirect enum PawnAction: Equatable {
    case move, attack, support, endTurn
    case compoundAction(PawnAction, PawnAction)
    
    var title: String {
        switch self {
        case .move: "Move"
        case .attack: "Attack"
        case .support: "Support"
        case .endTurn: "End Turn"
        case .compoundAction(let firstAction, let secondAction): "\(firstAction.title) & \(secondAction.title)"
        }
    }
    
    // Higher value == higher priority
    var displayPriority: Int {
        switch self {
        case .move: 0
        case .attack: 2
        case .support: 1
        case .endTurn: -1
        case .compoundAction(let firstAction, let secondAction): max(firstAction.displayPriority, secondAction.displayPriority)
        }
    }
}
