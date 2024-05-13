//
//  StrategySceneFlow.swift
//
//
//  Created by Joey Nelson on 5/10/24.
//

import Foundation
import SwiftGodot
import GDLasso

@Godot
class StrategySceneFlow: Node3D, SceneFlow {
    
    @SceneTree(path: "StrategyGrid") private var grid: StrategyGrid?
    
    private let gridStore = StrategyGridStore(with: .init())
    
    override func _ready() {
        grid?.set(store: gridStore.asNodeStore())
        
        if grid.isNull {
            GD.print("Grid is null.")
        }
        
        super._ready()
    }
}
