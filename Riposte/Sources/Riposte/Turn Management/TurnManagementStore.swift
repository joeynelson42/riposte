//
//  TurnManagementStore.swift
//
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation
import GDLasso

class TurnManagementStore: GDLassoStore<TurnManagementModule> {
    
    override func handleAction(_ externalAction: GDLassoStore<TurnManagementModule>.ExternalAction) {
        switch externalAction {
        case .initialize(let factions):
            let turnQueue = TurnQueue(factionOrder: factions)
            update { state in
                state.factions = factions
                state.turnQueue = turnQueue
            }
            dispatchOutput(.didStartTurn(state.activeFaction))
        case .endTurn:
            do {
                let previousFaction = state.activeFaction
                try state.turnQueue.endTurn()
                let newCurrentFaction = state.activeFaction

                if state.turnQueue.isQueueExhausted {
                    dispatchOutput(.didEndRound)
                    
                    let newTurnQueue = TurnQueue(factionOrder: state.turnQueue.factionOrder)
                    update { $0.turnQueue = newTurnQueue }
                    dispatchOutput(.didStartRound)
                    
                } else {
                    dispatchOutput(.didEndTurn(previousFaction))
                    dispatchOutput(.didStartTurn(newCurrentFaction))
                }
            } catch {
                print(error)
            }
        }
    }
    
}
