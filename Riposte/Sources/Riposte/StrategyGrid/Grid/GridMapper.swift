//
//  File.swift
//  
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation
import SwiftGodot

struct GridCellMapper {
    
    enum MapperError: Error {
        case rootNodeNotFound
    }
    
    private var queue = [StrategyGridCell]()
    
    private var cellPositions = [GridIndex: any StrategyGridCell]()
    
    mutating func createMap(from cells: [any StrategyGridCell], pawns: [any StrategyGridPawn]) throws -> StrategyGridMap {
        let root = try getRootCell(in: cells)
        var queue = [StrategyGridCell]()
        cellPositions[GridIndex(x: 0, y: 0)] = root
        
        queue.append(root)
        evaluateCell(root)
        
        log("Mapped \(cells.count) cell(s)")
        
        var pawnPositions = [GridIndex: any StrategyGridPawn]()
        pawns.forEach { pawn in
            if let pawnIndex = findPawnsNearestIndex(pawn: pawn, in: cellPositions) {
                log("Found a pawn at index: \(pawnIndex)")
                pawnPositions[pawnIndex] = pawn
                
                // Snap pawn to cell's xz position
                if let cellPos = cellPositions[pawnIndex]?._globalPosition {
                    let pawnSnapPos = Vector3(x: cellPos.x, y: pawn._globalPosition.y, z: cellPos.z)
                    pawn.setGlobalPosition(pawnSnapPos)
                }
            }
        }
        
        return StrategyGridMap(cells: cellPositions, pawns: pawnPositions)
    }
    
    private func getRootCell(in cells: [any StrategyGridCell]) throws -> any StrategyGridCell {
        var root: StrategyGridCell?
        
        for cell in cells {
            guard let currentRoot = root else {
                root = cell
                continue
            }
            
            let cellPosValue = cell._globalPosition.x + cell._globalPosition.z
            let currentRootPosValue = currentRoot._globalPosition.x + currentRoot._globalPosition.z
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
        
        if let index = queue.firstIndex(where: { $0.isEqualTo(item: cell) }) {
            queue.remove(at: index)
        }
        
        if let next = queue.first {
            evaluateCell(next)
        }
    }
    
    private mutating func evaluateNeighbor(_ originCell: StrategyGridCell, neighborDirection: Vector3) {
        guard let neighbor = findCellNeighbor(originCell, neighborDirection: neighborDirection),
              let originIndex = cellPositions.first(where: { $0.value.isEqualTo(item: originCell) })?.key
        else { return }
        
        let neighborIndex = GridIndex(x: originIndex.x + Int(neighborDirection.x), y: originIndex.y + Int(neighborDirection.z))
        if let _ = cellPositions.keys.firstIndex(of: neighborIndex) { return }
        cellPositions[neighborIndex] = neighbor
        queue.append(neighbor)
    }
    
    private func findCellNeighbor(_ originCell: StrategyGridCell, neighborDirection: Vector3) -> StrategyGridCell? {
        
        let rayStart = originCell._globalPosition
        let rayEnd = rayStart + neighborDirection * 10
        let rayQuery = PhysicsRayQueryParameters3D.create(from: rayStart, to: rayEnd, collisionMask: 0b0001)
        guard let result = originCell.world3D?.directSpaceState?.intersectRay(parameters: rayQuery),
              let collider = result["collider"],
              let node = Node3D.makeOrUnwrap(collider)
        else { return nil }
        
        return node as? StrategyGridCell
    }
    
    private func findPawnsNearestIndex(pawn: any StrategyGridPawn, in cellPositions: [GridIndex: any StrategyGridCell]) -> GridIndex? {
        var lowestDiff: Double?
        var currentNearestIndex: GridIndex?
        
        for (index, cell) in cellPositions {
            let diff = (cell._globalPosition - pawn._globalPosition).length()
            
            guard let currentLowest = lowestDiff else {
                lowestDiff = diff
                currentNearestIndex = index
                continue
            }
            
            if diff < currentLowest {
                lowestDiff = diff
                currentNearestIndex = index
            }
        }
        
        return currentNearestIndex
    }
}
