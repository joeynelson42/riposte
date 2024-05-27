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
        
        var start: GridIndex?
        var end: GridIndex?
        var currentPath: Path?
        
        var hovered: StrategyGridCell?
        var hoveredPath: Path?
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
    }
    
    enum Output {
        case didInitializeGrid(StrategyGridMap)
    }
}

