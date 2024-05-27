//
//  TurnManager.swift
//
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation
import SwiftGodot

/*
 
 ** Important Definitions **
 
 1. Turn: A faction's chance to act (e.g. move characters, launch attacks, etc.)
 
 2. Round: A collection of turns in the order the turns will take place
 
 3. Match: A collection of all the rounds
 
 */

enum TurnManagerState {
    case active, roundOver
}

protocol TurnManager {
    init(factions: [Faction])
    
    var currentFaction: Faction? { get }
    
    var currentState: TurnManagerState { get }
    
    func endTurn()
}
