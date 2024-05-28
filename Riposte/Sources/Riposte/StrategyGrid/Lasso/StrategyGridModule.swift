//
//  StrategyGridModule.swift
//  
//
//  Created by Joey Nelson on 5/10/24.
//

import Foundation
import SwiftGodot
import GDLasso

struct StrategyGridModule: SceneModule {
    
    struct State {
        var gridMap = StrategyGridMap()
        
        var selectedPawn: (any StrategyGridPawn)?
        
        var hovered: StrategyGridCell?
        var hoveredPath: Path?
        
        var currentActions: [String] = ["Hello", "World"]
    }
    
    enum ExternalAction {
        enum Input {
            case didClickCell(StrategyGridCell)
            case didHoverCell(StrategyGridCell)
            case didEndHovering
        }
        case input(Input)
        
        enum Turn {
            case didEndTurn(Faction)
            case didStartTurn(Faction)
        }
        case turn(Turn)
    }
    
    enum InternalAction {
        case onReady(gridCells: [StrategyGridCell], pawns: [any StrategyGridPawn])
        
        enum ActionList {
            case didSelectItem(index: Int)
        }
        case actionList(ActionList)
    }
    
    enum Output {
        case didInitializeGrid(StrategyGridMap)
    }
}

