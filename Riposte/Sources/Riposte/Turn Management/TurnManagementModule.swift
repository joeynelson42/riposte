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
        
        var activeFaction: Faction { turnQueue.activeFaction ?? .unknown }
        
        var turnQueue: TurnQueue
        
        init(factions: [Faction], style: TurnOrderStyle = .standard) {
            self.factions = factions
            
            turnQueue = TurnQueue(factionOrder: factions)
            
            turnOrderStyle = style
        }
    }
    
    enum ExternalAction {
        case initialize([Faction])
        case endTurn
    }
    
    enum Output {
        case didStartTurn(Faction)
        case didEndTurn(Faction)
        
        case didStartRound
        case didEndRound
    }
}
