//
//  StrategyGridCellNode.swift
//
//
//  Created by Joey Nelson on 5/4/24.
//

import Foundation
import SwiftGodot

@Godot
class StrategyGridCellNode: StaticBody3D, StrategyGridCell {
    
    @SceneTree(path: "PathIndicator") private var pathIndicator: Node3D?
    @SceneTree(path: "MoveIndicator") private var moveIndicator: Node3D?
    @SceneTree(path: "AttackIndicator") private var attackIndicator: Node3D?
    @SceneTree(path: "SupportIndicator") private var supportIndicator: Node3D?
    
    private lazy var indicators: [Node3D?] = [pathIndicator, moveIndicator, attackIndicator, supportIndicator]
    
    var world3D: World3D? { getWorld3d() }
    
    override func _ready() {
        hideIndicators()
        super._ready()
    }
    
    func showIndicator(type: StrategyGridCellIndicatorType) {
        switch type {
        case .none:
            hideIndicators()
        case .move:
            moveIndicator?.show()
        case .attack:
            attackIndicator?.show()
        case .support:
            supportIndicator?.show()
        }
    }
    
    func hideIndicators() {
        indicators.forEach { $0?.hide() }
    }
    
    func setGlobalPosition(_ position: SwiftGodot.Vector3) {
        globalPosition = position
    }
}
