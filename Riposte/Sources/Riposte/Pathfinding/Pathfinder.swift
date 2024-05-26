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
