//
//  Pathfinder.swift
//  
//
//  Created by Joey Nelson on 5/5/24.
//

import Foundation

protocol Pathfinder {
    func findPath(in nodes: [any PathNode], startNode: any PathNode, endNode: any PathNode) -> Path?
}

extension Pathfinder {
    func findPath(in map: StrategyGridMap, startIndex: GridIndex, endIndex: GridIndex) -> Path? {
        let startNode = SimplePathNode(index: startIndex)
        let endNode = SimplePathNode(index: endIndex)
        return findPath(in: map.unoccupiedPathNodes + [startNode, endNode], startNode: startNode, endNode: endNode)
    }
}
