//
//  File.swift
//  
//
//  Created by Joey Nelson on 5/10/24.
//

import Foundation
import SwiftGodot

struct StrategyGridModule: SceneModule {
    
    struct State {
        var clickedNode: Node3D?
    }
    
    enum Action {
        case didClickNode(Node3D)
    }
    
    enum Output {}
}

class StrategyGridStore: SceneStore<StrategyGridModule> {
    override func handleAction(_ action: SceneStore<StrategyGridModule>.Action) {
        switch action {
        case .didClickNode(let node):
            update { $0.clickedNode = node }
        }
    }
}
