//
//  TurnManagementModule.swift
//  
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation
import GDLasso

enum TurnOrderStyle {
    case standard, roundRobin
}

struct TurnManagementModule: SceneModule {
    
    struct State {
        var factions: [Faction]
        
        var turnOrderStyle: TurnOrderStyle
        
        var activeFaction: Faction
        
        var turnQueue: TurnQueue
        
        init(factions: [Faction], style: TurnOrderStyle = .standard) {
            self.factions = factions
            
            turnQueue = TurnQueue(factionOrder: factions)
            
            activeFaction = turnQueue.activeFaction ?? factions.first ?? .unknown
            
            turnOrderStyle = style
        }
    }
    
    enum ExternalAction {
        case endTurn
    }
    
    enum Output {
        case didStartTurn
        case didEndTurn
        
        case didStartRound
        case didEndRound
    }
}
