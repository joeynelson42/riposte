//
//  Path.swift
//
//
//  Created by Joey Nelson on 5/5/24.
//

import Foundation

struct Path: Equatable {
    
    static func == (lhs: Path, rhs: Path) -> Bool {
        return lhs.nodes.map { $0.index } == rhs.nodes.map { $0.index } && lhs.cost == rhs.cost
    }
    
    var nodes: [any PathNode]
    var cost: Int
}
