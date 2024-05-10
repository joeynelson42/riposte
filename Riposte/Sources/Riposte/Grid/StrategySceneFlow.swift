//
//  StrategySceneFlow.swift
//
//
//  Created by Joey Nelson on 5/10/24.
//

import Foundation
import SwiftGodot

@Godot
class StrategySceneFlow: Node3D, SceneFlow {
    
    var grid: StrategyGrid?
    
    var gridStore = StrategyGridStore(with: .init())
    
    override func _ready() {
        for child in getChildren() {
            if let child = child as? StrategyGrid {
                child.store = gridStore
                GD.print("Found grid. Set store.")
            }
        }
        
        super._ready()
    }
}
