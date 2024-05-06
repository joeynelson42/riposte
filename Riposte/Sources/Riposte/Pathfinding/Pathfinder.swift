//
//  Pathfinder.swift
//  
//
//  Created by Joey Nelson on 5/5/24.
//

import Foundation

protocol Pathfinder {
    func findPath(in nodes: [PathNode], startNode: PathNode, endNode: PathNode) -> Path?
}
