//
//  StrategyGridStore.swift
//  
//
//  Created by Joey Nelson on 5/13/24.
//

import Foundation
import GDLasso
import SwiftGodot

class StrategyGridStore: GDLassoStore<StrategyGridModule> {
    override func handleAction(_ internalaAction: GDLassoStore<StrategyGridModule>.InternalAction) {
        switch internalaAction {
        case .onReady(let gridCellNodes, let pawns):
            initializeGridMap(cells: gridCellNodes, pawns: pawns)
        }
    }
    
    override func handleAction(_ externalAction: GDLassoStore<StrategyGridModule>.ExternalAction) {
        switch externalAction {
        case .didClickCell(let cellNode):
            handleDidClickCell(cellNode)
        }
    }
    
    private func handleDidClickCell(_ cellNode: StrategyGridCellNode) {
        guard let gridIndex = state.gridMap.getIndexFor(cell: cellNode) else { return }
        GD.print("Did click cell at \(gridIndex)")
        
        if !state.start.isNull && !state.end.isNull {
            update { state in
                state.start = nil
                state.end = nil
                state.currentPath = nil
            }
        }
        
        if state.start.isNull {
            update { $0.start = gridIndex }
        } else if state.end.isNull {
            update { $0.end = gridIndex }
        }
        
        if let start = state.start, let end = state.end, let path = findPathBetween(start: start, end: end) {
            for (index, node) in path.nodes.enumerated() {
                GD.print("\(index): \(node.index)")
            }
            
            update { $0.currentPath = path }
            
            if let pawn = state.gridMap.pawnNodes.first {
                let globalPath = GlobalPath(steps: path.nodes.compactMap { state.gridMap.getCellAtIndex($0.index)?.globalPosition })
                Task {
                    await pawn.move(along: globalPath)
                }
            }
        }
    }
    
    private func initializeGridMap(cells: [StrategyGridCellNode], pawns: [any StrategyGridPawn]) {
        do {
            var mapper = GridCellMapper()
            let gridMap = try mapper.createMap(from: cells, pawns: pawns)
            update { $0.gridMap = gridMap }
        } catch {
            GD.print(error)
        }
    }
    
    private func findPathBetween(start: GridIndex, end: GridIndex) -> Path? {
        let pathfinder = AStarPathfinder()
        let startNode = StrategyGridCellModel(index: start)
        let endNode = StrategyGridCellModel(index: end)
        return pathfinder.findPath(in: state.gridMap.pathNodes, startNode: startNode, endNode: endNode)
    }
}

// TODO: too messy/ugly?
private struct GridCellMapper {
    
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
        
        GD.print("Mapped \(cells.count) cell(s)")
        
        var pawnPositions = [GridIndex: any StrategyGridPawn]()
        pawns.forEach { pawn in
            if let pawnIndex = findPawnsNearestIndex(pawn: pawn, in: cellPositions) {
                GD.print("Found a pawn at index: \(pawnIndex)")
                pawnPositions[pawnIndex] = pawn
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
            
            let cellPosValue = cell.globalPosition.x + cell.globalPosition.z
            let currentRootPosValue = currentRoot.globalPosition.x + currentRoot.globalPosition.z
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
              let originIndex = cellPositions.first(where: { $0.value.id == originCell.id })?.key
        else { return }
        
        let neighborIndex = GridIndex(x: originIndex.x + Int(neighborDirection.x), y: originIndex.y + Int(neighborDirection.z))
        if let _ = cellPositions.keys.firstIndex(of: neighborIndex) { return }
        cellPositions[neighborIndex] = neighbor
        queue.append(neighbor)
    }
    
    private func findCellNeighbor(_ originCell: StrategyGridCell, neighborDirection: Vector3) -> StrategyGridCell? {
        
        let rayStart = originCell.globalPosition
        let rayEnd = rayStart + neighborDirection * 10
        let rayQuery = PhysicsRayQueryParameters3D.create(from: rayStart, to: rayEnd, collisionMask: 0b0001)
        guard let result = originCell.world3D?.directSpaceState?.intersectRay(parameters: rayQuery),
              let collider = result["collider"],
              let node = Node3D.makeOrUnwrap(collider)
        else { return nil }
        
        return node as? StrategyGridCellNode
    }
    
    private func findPawnsNearestIndex(pawn: any StrategyGridPawn, in cellPositions: [GridIndex: any StrategyGridCell]) -> GridIndex? {
        var lowestDiff: Double?
        var currentNearestIndex: GridIndex?
        
        for (index, cell) in cellPositions {
            let diff = (cell.globalPosition - pawn.globalPosition).length()
            
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
