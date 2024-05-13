//
//  StrategyGridPawnNode.swift
//
//
//  Created by Joey Nelson on 5/13/24.
//

import Foundation
import SwiftGodot

@Godot
class StrategyGridPawnNode: Node3D, PawnMovable {
    
    var mover: SnapPawnMover? = SnapPawnMover()
    
}
