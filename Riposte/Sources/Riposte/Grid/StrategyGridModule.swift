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
        var cells: [GridIndex: StrategyGridCellNode] = [:]
        
        var start: GridIndex?
        var end: GridIndex?
    }
    
    enum ExternalAction {
        case didClickCell(StrategyGridCellNode)
    }
    
    enum InternalAction {
        case onReady(gridCells: [StrategyGridCellNode])
    }
    
    enum Output {}
}

