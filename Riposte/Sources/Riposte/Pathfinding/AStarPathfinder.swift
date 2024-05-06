//
//  AStarPathfinder.swift
//
//
//  Created by Joey Nelson on 5/5/24.
//

import Foundation
import SwiftGodot

struct AStarPathfinder: Pathfinder {
    
    private class AStarNode: PathNode, Equatable {
        static func == (lhs: AStarPathfinder.AStarNode, rhs: AStarPathfinder.AStarNode) -> Bool {
            return lhs.index == rhs.index
        }
        
        var index: GridIndex
        var weight: Float = 10
        var parent: AStarNode?
        var neighbors: [AStarNode] = []
        var gCost: Float = 0
        var hCost: Float = 0
        var fCost: Float { weight + gCost + hCost }
        
        init(index: GridIndex) {
            self.index = index
        }
    }
    
    func findPath(in nodes: [PathNode], startNode: PathNode, endNode: PathNode) -> Path? {
        var aStarNodes = nodes.map { AStarNode(index: $0.index) }
        aStarNodes.forEach { $0.neighbors = findNodeNeighbors($0, nodes: aStarNodes) }
        
        guard let start = getNodeAtIndex(startNode.index, nodes: aStarNodes),
              let end = getNodeAtIndex(endNode.index, nodes: aStarNodes),
              let pathNodes = findPath(in: aStarNodes, startNode: start, endNode: end)
        else { return nil }
        
        return Path(nodes: pathNodes, cost: 0)
    }
    
    private func findPath(in nodes: [AStarNode], startNode: AStarNode, endNode: AStarNode) -> [AStarNode]? {
        
        var openSet = [AStarNode]()
        var closedSet = [AStarNode]()
        
        openSet.append(startNode)
        
        while !openSet.isEmpty {
            var currentNode = openSet[0]
            
            for i in 1..<openSet.count {
                if (openSet[i].fCost < currentNode.fCost || openSet[i].fCost == currentNode.fCost) {
                    if (openSet[i].hCost < currentNode.hCost) {
                        currentNode = openSet[i];
                    }
                }
            }
            
            if let index = openSet.firstIndex(of: currentNode) {
                openSet.remove(at: index)
            }
            closedSet.append(currentNode)
            
            if (currentNode == endNode)
            {
                return retracePath(start: startNode, end: endNode)
            }
            
            for neighbor in currentNode.neighbors {
                if !nodes.contains(neighbor) || closedSet.contains(neighbor) { continue }
                
                var newMovementCostToNeighbor = currentNode.gCost + getDistanceBetween(from: currentNode, to: neighbor)
                if (newMovementCostToNeighbor < neighbor.gCost || !openSet.contains(neighbor)) {
                    neighbor.gCost = newMovementCostToNeighbor + neighbor.weight;
                    neighbor.hCost = getDistanceBetween(from: neighbor, to: endNode) + neighbor.weight;
                    neighbor.parent = currentNode;
                    
                    if (!openSet.contains(neighbor)) {
                        openSet.append(neighbor);
                    }
                }
            }
        }
        
        return nil
    }
    
    private func retracePath(start: AStarNode, end: AStarNode) -> [AStarNode] {
        var path = [AStarNode]()
        var currentNode = end
        
        while currentNode != start {
            path.append(currentNode)
            guard let parent = currentNode.parent else { break }
            currentNode = parent
        }
        path.append(start)
        path.reverse()
        return path
    }
    
    private func getDistanceBetween(from: AStarNode, to: AStarNode) -> Float {
        var xDistance = Float(abs(from.index.x - to.index.x))
        var yDistance = Float(abs(from.index.y - to.index.y))
        
        if xDistance > yDistance {
            return 14 * yDistance + 10 * (xDistance - yDistance)
        } else {
            return 14 * xDistance + 10 * (yDistance - xDistance)
        }
    }
    
    private func findNodeNeighbors(_ node: AStarNode, nodes: [AStarNode]) -> [AStarNode] {
        return GridIndex.Direction.allCases.compactMap { getNodeAtIndex(node.index + $0.value, nodes: nodes) }
    }
    
    private func getNodeAtIndex(_ index: GridIndex, nodes: [AStarNode]) -> AStarNode? {
        return nodes.first(where: { $0.index == index })
    }
}
