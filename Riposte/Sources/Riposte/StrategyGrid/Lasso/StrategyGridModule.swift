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
    }
    
    enum ExternalAction {
        case didClickCell(StrategyGridCell)
    }
    
    enum InternalAction {
        case onReady(gridCells: [StrategyGridCell], pawns: [any StrategyGridPawn])
    }
    
    enum Output {}
}

