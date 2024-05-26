//
//  StrategyGridPawnNode.swift
//
//
//  Created by Joey Nelson on 5/13/24.
//

import Foundation
import SwiftGodot

protocol GloballyPositioned {
    var globalPosition: Vector3 { get }
    
    func setGlobalPosition(_ position: Vector3)
}

protocol StrategyGridPawn: PawnMovable, GloballyPositioned, NodeEquatable {
    
}

protocol NodeEquatable {
    
    var id: ObjectIdentifier { get }
    
    func isEqualTo(item: NodeEquatable) -> Bool
}

extension NodeEquatable {
    func isEqualTo(item: NodeEquatable) -> Bool {
        return item.id == self.id
    }
}

@Godot
class StrategyGridPawnNode: CharacterBody3D, StrategyGridPawn {
    
    var mover: some PawnMover = SnapPawnMover()
    
    @Export(.range, "0,2,")
    private var factionValue: Int = 0
    
    public var faction: Faction { Faction(rawValue: factionValue) ?? .unknown }
    
    func setGlobalPosition(_ position: Vector3) {
        globalPosition = position
    }
}
