//
//  SimpleTurnManager.swift
//
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation
import SwiftGodot

class SimpleTurnManager: TurnManager {
    
    var currentState: TurnManagerState
    
    private var turnQueue: TurnQueue
    
    private var turnHistory = [[Faction]]()
    
    required init(factions: [Faction]) {
        turnQueue = TurnQueue(factionOrder: factions)
        currentState = .active
    }
    
    var currentFaction: Faction? {
        return turnQueue.activeFaction
    }
    
    func endTurn() {
        do {
            try turnQueue.endTurn()
        } catch {
            GD.print(error)
        }
        
        if turnQueue.isQueueExhausted {
            turnHistory.append(turnQueue.factionOrder)
            currentState = .roundOver
        }
    }
    
    func startNewRound() {
        guard let lastTurn = turnHistory.last else { return }
        turnQueue = TurnQueue(factionOrder: lastTurn)
        currentState = .active
    }
}
