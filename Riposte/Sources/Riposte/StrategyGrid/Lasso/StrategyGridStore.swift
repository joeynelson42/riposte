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
            update { $0.activePawns = [] }
        case .didStartTurn(let faction):
            let activePawns = state.gridMap.pawnNodes.filter { $0.faction == faction }
            update { state in
                state.activeFaction = faction
                state.activePawns = activePawns
            }
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
            log(error)
        }
    }
    
    private func findPathBetween(start: GridIndex, end: GridIndex) -> Path? {
        let pathfinder = AStarPathfinder()
        let startNode = SimplePathNode(index: start)
        let endNode = SimplePathNode(index: end)
        return pathfinder.findPath(in: state.gridMap.unoccupiedPathNodes + [startNode], startNode: startNode, endNode: endNode)
    }
}

// MARK: Cell Selection
extension StrategyGridStore {
    
    private func isPawnActive(_ pawn: any StrategyGridPawn) -> Bool {
        return state.activePawns.contains(where: { $0.isEqualTo(item: pawn) })
    }
    
    private func handleDidClickCell(_ cell: StrategyGridCell) {
        guard let gridIndex = state.gridMap.getIndexFor(cell: cell) else { return }
        log("Did click cell at \(gridIndex)")
        
        if let clickedPawn = state.gridMap.getPawnAtIndex(gridIndex) {
            handleDidSelectOccupiedCell(cell, occupant: clickedPawn)
        } else {
            handleDidSelectEmptyCell(cell)
        }
    }
    
    private func handleDidSelectEmptyCell(_ cell: StrategyGridCell) {
        if let selectedPawn = state.selectedPawn {
            log("Did click empty cell with selected pawn")
            guard let start = state.gridMap.getIndexFor(pawn: selectedPawn),
                  let end = state.gridMap.getIndexFor(cell: cell),
                  let path = findPathBetween(start: start, end: end)
            else { return }
            
            update { $0.currentActions = ["Move"] }
            
            let globalSteps = path.nodes.compactMap { state.gridMap.getCellAtIndex($0.index)?.globalPosition }
            
            Task {
                await selectedPawn.move(along: GlobalPath(steps: globalSteps))
                
                var activePawns = state.activePawns
                activePawns.removeAll(where: { $0.isEqualTo(item: selectedPawn) })
                update { [weak self] state in
                    do {
                        try state.gridMap.setPawnIndex(pawn: selectedPawn, index: end)
                        state.selectedPawn = nil
                        state.activePawns = activePawns
                        if state.activePawns.isEmpty {
                            self?.dispatchOutput(.didExhaustAllActivePawns)
                        }
                    } catch {
                        log(error)
                    }
                }
            }
        } else {
            log("Did click empty cell, no selected pawn")
        }
    }
    
    private func handleDidSelectOccupiedCell(_ cell: StrategyGridCell, occupant: any StrategyGridPawn) {
        if let selectedPawn = state.selectedPawn {
            if selectedPawn.faction != occupant.faction {
                log("Did click occupied cell, selected pawn, attack!")
                update { $0.currentActions = ["Attack!"] }
            } else {
                log("Did click occupied cell, selected pawn, support")
            }
        } else if isPawnActive(occupant) {
            log("Selected active pawn")
            update { $0.selectedPawn = occupant }
        } else {
            log("Selected inactive pawn")
        }
    }
}
