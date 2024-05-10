//
//  StrategyGrid.swift
//
//
//  Created by Joey Nelson on 5/4/24.
//

import Foundation
import SwiftGodot

@Godot
class StrategyGrid: Node3D, SceneNode {
    
    typealias Store = StrategyGridStore
    
    var store: Store? {
        didSet {
            setupBindings()
        }
    }
    
    private(set) var cells: [GridIndex: StrategyGridCellNode] = [:]
    
    private var start: GridIndex?
    private var end: GridIndex?
    
    override func _ready() {
        initialize()
        super._ready()
    }
    
    private func initialize() {
        do {
            let allCells = getChildren().compactMap { $0 as? StrategyGridCellNode }
            var mapper = GridCellMapper()
            cells = try mapper.mapCellPositions(allCells)
        } catch {
            GD.print(error)
        }
    }
    
    private func setupBindings() {
        guard let store else { return }
        
        store.observeState(\.clickedNode) { old, node in
            guard let node else { return }
            GD.print("Observed that \(node) was clicked.")
        }
    }
    
    override func _input(event: InputEvent) {
        guard let targetNode = try? MouseInputUtil.getNodeAtMousePosition(from: self) as? StrategyGridCellNode,
              let targetIndex = getIndex(of: targetNode)
        else { return }
        
        
        switch event {
        case is InputEventMouseButton:
            if !event.isPressed() {
                store?.dispatchAction(.didClickNode(targetNode))
//                GD.print(targetIndex)
//                if start == nil {
//                    start = getIndex(of: targetNode)
//                    GD.print("set start")
//                } else if end == nil {
//                    end = getIndex(of: targetNode)
//                    GD.print("set end\n")
//                    
//                    if let start, let end {
//                        let pathNodes = cells.keys.map { StrategyGridCell(index: $0) }
//                        let pathfinder = AStarPathfinder()
//                        let startNode = StrategyGridCell(index: start)
//                        let endNode = StrategyGridCell(index: end)
//                        
//                        self.start = nil
//                        self.end = nil
//                        
//                        guard let path = pathfinder.findPath(in: pathNodes, startNode: startNode, endNode: endNode) else { return }
//                        
//                        for (index, node) in path.nodes.enumerated() {
//                            GD.print("\(index): \(node.index)")
//                        }
//                    }
//                }
            }
        case is InputEventMouseMotion:
            break
        default:
            return
        }
    }
    
    private func getIndex(of cell: StrategyGridCellNode) -> GridIndex? {
        return cells.first(where: { $0.value.id == cell.id })?.key
    }
}

// TODO: too messy/ugly
private struct GridCellMapper {
    
    enum MapperError: Error {
        case rootNodeNotFound
    }
    
    private var queue = [StrategyGridCellNode]()
    
    private var positions = [GridIndex: StrategyGridCellNode]()
    
    mutating func mapCellPositions(_ cells: [StrategyGridCellNode]) throws -> [GridIndex: StrategyGridCellNode] {
        let root = try getRootCell(in: cells)
        var queue = [StrategyGridCellNode]()
        positions[GridIndex(x: 0, y: 0)] = root
        
        queue.append(root)
        evaluateCell(root)
        
        GD.print("Mapped \(cells.count) cell(s)")
        
        return positions
    }
    
    private func getRootCell(in cells: [StrategyGridCellNode]) throws -> StrategyGridCellNode {
        var root: StrategyGridCellNode?
        
        for cell in cells {
            guard let currentRoot = root else {
                root = cell
                continue
            }
            
            let cellPosValue = cell.transform.origin.x + cell.transform.origin.z
            let currentRootPosValue = currentRoot.transform.origin.x + currentRoot.transform.origin.z
            if cellPosValue < currentRootPosValue {
                root = cell
            }
        }
        
        guard let root else { throw MapperError.rootNodeNotFound }
        return root
    }
    
    private mutating func evaluateCell(_ cell: StrategyGridCellNode) {
        evaluateNeighbor(cell, neighborDirection: Vector3.forward)
        evaluateNeighbor(cell, neighborDirection: Vector3.back)
        evaluateNeighbor(cell, neighborDirection: Vector3.right)
        evaluateNeighbor(cell, neighborDirection: Vector3.left)
        
        if let index = queue.firstIndex(of: cell) {
            queue.remove(at: index)
        }
        
        if let next = queue.first {
            evaluateCell(next)
        }
    }
    
    private mutating func evaluateNeighbor(_ originCell: StrategyGridCellNode, neighborDirection: Vector3) {
        guard let neighbor = findCellNeighbor(originCell, neighborDirection: neighborDirection),
              let originIndex = positions.first(where: { $0.value.id == originCell.id })?.key
        else { return }
        
        let neighborIndex = GridIndex(x: originIndex.x + Int(neighborDirection.x), y: originIndex.y + Int(neighborDirection.z))
        if let _ = positions.keys.firstIndex(of: neighborIndex) { return }
        positions[neighborIndex] = neighbor
        queue.append(neighbor)
    }
    
    private func findCellNeighbor(_ originCell: StrategyGridCellNode, neighborDirection: Vector3) -> StrategyGridCellNode? {
        
        let rayStart = originCell.globalPosition
        let rayEnd = rayStart + neighborDirection * 10
        let rayQuery = PhysicsRayQueryParameters3D.create(from: rayStart, to: rayEnd, collisionMask: 0b0001)
        guard let result = originCell.getWorld3d()?.directSpaceState?.intersectRay(parameters: rayQuery),
              let collider = result["collider"],
              let node = Node3D.makeOrUnwrap(collider)
        else { return nil }
        
        return node as? StrategyGridCellNode
    }
}
