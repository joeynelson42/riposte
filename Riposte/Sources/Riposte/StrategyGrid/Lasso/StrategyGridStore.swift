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
        case .onReady(let cells, let pawns):
            initializeGridMap(cells: cells, pawns: pawns)
        }
    }
    
    override func handleAction(_ externalAction: GDLassoStore<StrategyGridModule>.ExternalAction) {
        switch externalAction {
        case .didClickCell(let cell):
            handleDidClickCell(cell)
        case .didHoverCell(let cell):
            handleDidHoverCell(cell)
        case .didEndHovering:
            break
        }
    }
    
    private func handleDidClickCell(_ cell: StrategyGridCell) {
        guard let gridIndex = state.gridMap.getIndexFor(cell: cell) else { return }
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
    
    private func handleDidHoverCell(_ cell: StrategyGridCell) {
        update { $0.hovered = cell }
        
        guard let start = state.start, 
              let hoveredIndex = state.gridMap.getIndexFor(cell: cell),
              let hoveredPath = findPathBetween(start: start, end: hoveredIndex)
        else { return }
        
        update { $0.hoveredPath = hoveredPath }
    }
    
    private func handleDidEndHovering() {
        update {
            $0.hovered = nil
            $0.hoveredPath = nil
        }
    }
    
    private func initializeGridMap(cells: [any StrategyGridCell], pawns: [any StrategyGridPawn]) {
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
        let startNode = SimplePathNode(index: start)
        let endNode = SimplePathNode(index: end)
        return pathfinder.findPath(in: state.gridMap.pathNodes, startNode: startNode, endNode: endNode)
    }
}
