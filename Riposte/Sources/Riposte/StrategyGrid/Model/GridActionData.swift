//
//  File.swift
//  
//
//  Created by Joey Nelson on 6/1/24.
//

import Foundation

struct GridActionData {
        
    var pawnFaction: Faction
    
    var occupyingFaction: Faction?
    
    var isOccupied: Bool { occupyingFaction != nil }
    
    var isWithinMovementRange: Bool
    
}
