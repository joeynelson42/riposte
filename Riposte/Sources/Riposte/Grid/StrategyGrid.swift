//
//  StrategyGrid.swift
//
//
//  Created by Joey Nelson on 5/4/24.
//

import Foundation
import SwiftGodot
import GDLasso

@Godot
class StrategyGrid: Node3D, SceneNode {
    
    var store: StrategyGridModule.NodeStore?
    
    override func _ready() {
        initialize()
        super._ready()
    }
    
    private func initialize() {
        
        
    }
    
    func setUpObservations() {
        let allCells = getChildren().compactMap { $0 as? StrategyGridCellNode }
        dispatchInternalAction(.onReady(gridCells: allCells))
    }
}
