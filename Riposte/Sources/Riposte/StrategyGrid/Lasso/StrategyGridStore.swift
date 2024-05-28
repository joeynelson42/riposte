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
    
    // MARK: Internal
    
    override func handleAction(_ internalaAction: GDLassoStore<StrategyGridModule>.InternalAction) {
        switch internalaAction {
        case .onReady(let cells, let pawns):
            initializeGridMap(cells: cells, pawns: pawns)
        case .actionList(let listAction):
            handleActionList(action: listAction)
        }
    }
    
    private func handleActionList(action: StrategyGridModule.InternalAction.ActionList) {
        switch action {
        case .didSelectItem(index: let index):
            let actions = (0..<Int.random(in: 0...5)).map { "\($0)" } + ["hello"]
            update { $0.currentActions = actions }
        }
    }
    
    // MARK: External
    
    override func handleAction(_ externalAction: GDLassoStore<StrategyGridModule>.ExternalAction) {
        switch externalAction {
        case .input(let inputAction):
            handleInput(action: inputAction)
        case .turn(let turnAction):
            handleTurn(action: turnAction)
        }
    }
    
    private func handleInput(action: StrategyGridModule.ExternalAction.Input) {
        switch action {
        case .didClickCell(let cell):
            handleDidClickCell(cell)
        case .didHoverCell(let cell):
            handleDidHoverCell(cell)
        case .didEndHovering:
            break
        }
    }
    
    private func handleTurn(action: StrategyGridModule.ExternalAction.Turn) {
        switch action {
        case .didEndTurn(let faction):
            break
        case .didStartTurn(let faction):
            break
        }
    }
    
    private func handleDidClickCell(_ cell: StrategyGridCell) {
        guard let gridIndex = state.gridMap.getIndexFor(cell: cell) else { return }
        GD.print("Did click cell at \(gridIndex)")
        
        if let clickedPawn = state.gridMap.getPawnAtIndex(gridIndex) {
            handleDidSelectOccupiedCell(cell, occupant: clickedPawn)
        } else {
            handleDidSelectEmptyCell(cell)
        }
    }
    
    private func handleDidSelectEmptyCell(_ cell: StrategyGridCell) {
        if let selectedPawn = state.selectedPawn {
            guard let start = state.gridMap.getIndexFor(pawn: selectedPawn), 
                  let end = state.gridMap.getIndexFor(cell: cell),
                  let path = findPathBetween(start: start, end: end)
            else { return }
            
            GD.print("Did click empty cell with selected pawn")
            update { $0.currentActions = ["Move"] }
            
            let globalSteps = path.nodes.compactMap { state.gridMap.getCellAtIndex($0.index)?.globalPosition }
            
            Task {
                await selectedPawn.move(along: GlobalPath(steps: globalSteps))
                update {
                    do {
                        try $0.gridMap.setPawnIndex(pawn: selectedPawn, index: end)
                    } catch {
                        Log(error)
                    }
                }
            }
        } else {
            GD.print("Did click empty cell, no selected pawn")
        }
    }
    
    private func handleDidSelectOccupiedCell(_ cell: StrategyGridCell, occupant: any StrategyGridPawn) {
        if let selectedPawn = state.selectedPawn {
            if selectedPawn.faction != occupant.faction {
                GD.print("Did click occupied cell, selected pawn, attack!")
                update { $0.currentActions = ["Attack!"] }
            } else {
                GD.print("Did click occupied cell, selected pawn, support")
            }
        } else {
            GD.print("Did click occupied cell, no selected pawn")
            update { $0.selectedPawn = occupant }
        }
    }
    
    private func handleDidHoverCell(_ cell: StrategyGridCell) {
        update { $0.hovered = cell }
        
        guard let selectedPawn = state.selectedPawn,
              let pawnIndex = state.gridMap.getIndexFor(pawn: selectedPawn),
              let hoveredIndex = state.gridMap.getIndexFor(cell: cell),
              let hoveredPath = findPathBetween(start: pawnIndex, end: hoveredIndex)
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
            dispatchOutput(.didInitializeGrid(gridMap))
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
