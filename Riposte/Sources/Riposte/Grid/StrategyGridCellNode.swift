//
//  StrategyGridCellNode.swift
//
//
//  Created by Joey Nelson on 5/4/24.
//

import Foundation
import SwiftGodot

@Godot
class StrategyGridCellNode: StaticBody3D {
    @SceneTree(path: "PathIndicator") private var pathIndicator: Node3D?
    
    override func _ready() {
        setPathIndicator(hidden: true)
        super._ready()
    }
    
    public func setPathIndicator(hidden: Bool) {
        if hidden {
            pathIndicator?.hide()
        } else {
            pathIndicator?.show()
        }
    }
}
