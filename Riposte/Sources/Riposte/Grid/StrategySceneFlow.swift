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
    
    @SceneTree(path: "StrategyGrid") var grid: StrategyGrid?
    
    var gridStore = StrategyGridStore(with: .init())
    
    override func _ready() {
        if var grid {
            grid.set(store: gridStore.asNodeStore())
            GD.print("Set Grid Store")
        }
        super._ready()
    }
}
