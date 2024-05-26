//
//  StrategyGridCellNode.swift
//
//
//  Created by Joey Nelson on 5/4/24.
//

import Foundation
import SwiftGodot

protocol WorldAware {
    var world3D: World3D? { get }
}

protocol StrategyGridCell: GloballyPositioned, NodeEquatable, WorldAware {
    func setPathIndicator(hidden: Bool)
}

@Godot
class StrategyGridCellNode: StaticBody3D, StrategyGridCell {
    @SceneTree(path: "PathIndicator") private var pathIndicator: Node3D?
    
    var world3D: World3D? { getWorld3d() }
    
    override func _ready() {
        setPathIndicator(hidden: true)
        super._ready()
    }
    
    func setPathIndicator(hidden: Bool) {
        if hidden {
            pathIndicator?.hide()
        } else {
            pathIndicator?.show()
        }
    }
    
    func setGlobalPosition(_ position: SwiftGodot.Vector3) {
        globalPosition = position
    }
}
