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
            if let action = state.currentActions[safe: index], let selectedPawn = state.selectedPawn, let targetCell = state.selectedCell {
                Task {
                    await execute(action: action, actingPawn: selectedPawn, targetCell: targetCell)
                }
            } else if index == state.currentActions.count {
                // Cancel
                update { $0.selectedCell = nil }
            }
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
//            handleDidHoverCell(cell)
            break
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
            let activePool = FactionActionPool(pawns: activePawns)
            update { state in
                state.activeFaction = faction
                state.activePawns = activePawns
                state.activeActionPool = activePool
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

// MARK: Action Execution
extension StrategyGridStore {
    
    @MainActor
    private func execute(action: PawnAction, actingPawn: any StrategyGridPawn, targetCell: StrategyGridCell) async {
        guard let pawnIndex = state.gridMap.getIndexFor(pawn: actingPawn), let cellIndex = state.gridMap.getIndexFor(cell: targetCell) else { return }
        log("execute \(action.title.lowercased()) action from pawn at \(pawnIndex) on cell at index \(cellIndex)")
        
        // Perform action
        switch action {
        case .move:
            await executeMove(actingPawn: actingPawn, targetCell: targetCell)
        case .attack:
            break
        case .support:
            break
        case .endTurn:
            break
        case .compoundAction(let first, let second):
            await execute(action: first, actingPawn: actingPawn, targetCell: targetCell)
            await execute(action: second, actingPawn: actingPawn, targetCell: targetCell)
        }
        
        // Exhaust action
        update { state in
            do {
                try state.activeActionPool?.exhaust(action: action, for: actingPawn)
            } catch {
                log("Failed to exhaust pawn's grid action with error: \(error)")
            }
        }
        
        // Deselect cell and pawn
        update { state in
            state.selectedPawn = nil
            state.selectedCell = nil
        }
    }
    
    /// Moves the given pawn to the given cell asynchronously
    @MainActor
    private func executeMove(actingPawn: any StrategyGridPawn, targetCell: StrategyGridCell) async {
        guard let pawnIndex = state.gridMap.getIndexFor(pawn: actingPawn), 
              let cellIndex = state.gridMap.getIndexFor(cell: targetCell),
              let path = findPathBetween(start: pawnIndex, end: cellIndex)
        else { return }
        
        let globalSteps = path.nodes.compactMap { state.gridMap.getCellAtIndex($0.index)?._globalPosition }
        await actingPawn.move(along: GlobalPath(steps: globalSteps))
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
            update { $0.selectedCell = cell }
            
//            guard let start = state.gridMap.getIndexFor(pawn: selectedPawn),
//                  let end = state.gridMap.getIndexFor(cell: cell),
//                  let path = findPathBetween(start: start, end: end)
//            else { return }
            
//            update { $0.currentActions = ["Move"] }
//            
//            let globalSteps = path.nodes.compactMap { state.gridMap.getCellAtIndex($0.index)?.globalPosition }
//            
//            Task {
//                await selectedPawn.move(along: GlobalPath(steps: globalSteps))
//                
//                update { [weak self] state in
//                    do {
//                        try state.gridMap.setPawnIndex(pawn: selectedPawn, index: end)
//                        state.selectedPawn = nil
//                    } catch {
//                        log(error)
//                    }
//                }
//                
//                exhaustPawn(selectedPawn)
//            }
        } else {
            log("Did click empty cell, no selected pawn")
        }
    }
    
    private func handleDidSelectOccupiedCell(_ cell: StrategyGridCell, occupant: any StrategyGridPawn) {
        update { $0.selectedCell = cell }
        
        if let selectedPawn = state.selectedPawn {
            update { $0.selectedCell = cell }
        } else if isPawnActive(occupant) {
            log("No active pawn. Selected active pawn")
            update { $0.selectedPawn = occupant }
        } else {
            log("No active pawn. Selected inactive pawn")
        }
    }
    
//    private func exhaustPawn(_ pawn: any StrategyGridPawn) {
//        var activePawns = state.activePawns
//        activePawns.removeAll(where: { $0.isEqualTo(item: pawn) })
//        update { [weak self] state in
//            state.activePawns = activePawns
//            if state.activePawns.isEmpty {
//                self?.dispatchOutput(.didExhaustAllActivePawns)
//            }
//        }
//    }
}

/*
 
 REVISED
 1. Turn starts
 2. User selects active pawn
 3. Store evaluates possible actions
 4. Store displays moveable tiles as blue and attackable tiles as red and supportable tiles as green, other tiles have no indication
 5. User selects valid cell
 6. Store evaluates which actions are possible at selected cell
 7. Displays possible actions in UI
 8. User selects action
 9. Store state now has selectedPawn and selectedAction
 10. Store executes the selectedAction on the selectedCell
 11. Store repeats steps 3-10 until no more actions are left or turn is explicitly ended by user or selects another pawn

 */
