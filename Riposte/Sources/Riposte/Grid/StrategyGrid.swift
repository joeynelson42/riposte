//
//  StrategyGrid.swift
//
//
//  Created by Joey Nelson on 5/4/24.
//

import Foundation
import SwiftGodot

@Godot
class StrategyGrid: Node3D {
    
    private var cells: [GridIndex: StrategyGridCell] = [:]
    
    override func _ready() {
        
        do {
            let allCells = getChildren().compactMap { $0 as? StrategyGridCell }
            var mapper = GridCellMapper()
            cells = try mapper.mapCellPositions(allCells)
            GD.print("found \(cells.count) cell(s)")
        } catch {
            print(error)
        }
        
        super._ready()
    }
    
    override func _input(event: InputEvent) {
        guard let targetNode = try? MouseInputUtil.getNodeAtMousePosition(from: self) as? StrategyGridCell,
              let targetIndex = getIndex(of: targetNode)
        else { return }
        
        
        switch event {
        case is InputEventMouseButton:
            if !event.isPressed() {
                GD.print(targetIndex)
            }
        case is InputEventMouseMotion:
            break
        default:
            return
        }
    }
    
    private func getIndex(of cell: StrategyGridCell) -> GridIndex? {
        return cells.first(where: { $0.value.id == cell.id })?.key
    }
}

// TODO: too messy/ugly
private struct GridCellMapper {
    
    enum MapperError: Error {
        case rootNodeNotFound
    }
    
    private var queue = [StrategyGridCell]()
    
    private var positions = [GridIndex: StrategyGridCell]()
    
    mutating func mapCellPositions(_ cells: [StrategyGridCell]) throws -> [GridIndex: StrategyGridCell] {
        let root = try getRootCell(in: cells)
        var queue = [StrategyGridCell]()
        positions[GridIndex(x: 0, y: 0)] = root
        
        queue.append(root)
        evaluateCell(root)
        
        return positions
    }
    
    private func getRootCell(in cells: [StrategyGridCell]) throws -> StrategyGridCell {
        var root: StrategyGridCell?
        
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
    
    private mutating func evaluateCell(_ cell: StrategyGridCell) {
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
    
    private mutating func evaluateNeighbor(_ originCell: StrategyGridCell, neighborDirection: Vector3) {
        guard let neighbor = findCellNeighbor(originCell, neighborDirection: neighborDirection),
              let originIndex = positions.first(where: { $0.value.id == originCell.id })?.key
        else { return }
        
        let neighborIndex = GridIndex(x: originIndex.x + Int(neighborDirection.x), y: originIndex.y + Int(neighborDirection.z))
        if let _ = positions.keys.firstIndex(of: neighborIndex) { return }
        positions[neighborIndex] = neighbor
        queue.append(neighbor)
    }
    
    private func findCellNeighbor(_ originCell: StrategyGridCell, neighborDirection: Vector3) -> StrategyGridCell? {
        
        let rayStart = originCell.globalPosition
        let rayEnd = rayStart + neighborDirection * 10
        let rayQuery = PhysicsRayQueryParameters3D.create(from: rayStart, to: rayEnd, collisionMask: 0b0001)
        guard let result = originCell.getWorld3d()?.directSpaceState?.intersectRay(parameters: rayQuery),
              let collider = result["collider"],
              let node = Node3D.makeOrUnwrap(collider)
        else { return nil }
        
        return node as? StrategyGridCell
    }
}
