//
//  StrategyGridPawn.swift
//  
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation

protocol StrategyGridPawn: PawnMovable, GloballyPositioned, NodeEquatable {
    
    var faction: Faction { get }
    
}
