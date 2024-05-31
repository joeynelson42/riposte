//
//  StrategyGridPawnNode.swift
//
//
//  Created by Joey Nelson on 5/13/24.
//

import Foundation
import SwiftGodot

@Godot
class StrategyGridPawnNode: CharacterBody3D, StrategyGridPawn {
    
    var mover: some PawnMover = SnapPawnMover()
    
    @Export(.range, "0,2,")
    private var factionValue: Int = 0
    
    public var faction: Faction { Faction(rawValue: factionValue) ?? .unknown }
    
    @Export
    public var moveDistance: Int = 4
}
