//
//  StagedBattle.swift
//
//
//  Created by Joey Nelson on 6/1/24.
//

import Foundation

struct StagedBattle {
    
    enum StagedBattleError: Error {
        case duplicateDirection
        case notNeighbor
    }
    
    struct Participant {
        
        enum ActionType {
            case support, attack
        }
        
        var pawn: any StrategyGridPawn
        
        var direction: GridIndex.Direction
        
        var actionType: ActionType
    }
    
    var targetPawn: any StrategyGridPawn
    
    var participants: [Participant]
    
    init(targetPawn: any StrategyGridPawn, initialParticipant: Participant) {
        self.targetPawn = targetPawn
        self.participants = [initialParticipant]
    }
    
    mutating func addParticipant(_ participant: Participant) throws {
        if participants.contains(where: { $0.direction == participant.direction }) { throw StagedBattleError.duplicateDirection }
        participants.append(participant)
    }
}
