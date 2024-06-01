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
    
    private let turnStore = TurnManagementStore(with: .init(factions: []))
    
    required init(with initialState: GDLassoStore<StrategyGridModule>.State) {
        super.init(with: initialState)
        turnStore.observeOutput(observeTurnOutput(_:))
    }
    
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
            log("did select index \(index)")
            
            if let action = state.currentActions[safe: index], let selectedPawn = state.selectedPawn, let targetCell = state.selectedCell {
                Task {
                    await execute(action: action, actingPawn: selectedPawn, targetCell: targetCell)
                    
                    // Deselect cell and pawn
                    update { state in
                        state.selectedPawn = nil
                        state.selectedCell = nil
                    }
                    
                    // If no more active pawns, inform the flow
                    if state.activePawns.isEmpty {
                        turnStore.dispatchExternalAction(.endTurn)
                    }
                }
            } else if index == state.currentActions.count {
                // Cancel
                update { state in
                    state.selectedCell = nil
                    state.selectedPawn = nil
                }
            }
        }
    }
    
    // MARK: External
    
    override func handleAction(_ externalAction: GDLassoStore<StrategyGridModule>.ExternalAction) {
        switch externalAction {
        case .input(let inputAction):
            handleInput(action: inputAction)
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
            
            let factions = Set(gridMap.pawnNodes.map { $0.faction })
            turnStore.dispatchExternalAction(.initialize(Array(factions)))
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
    
    private func isPawnInBattle(_ pawn: any StrategyGridPawn) -> Bool {
        for (index, battle) in state.stagedBattles {
            if battle.targetPawn.isEqualTo(item: pawn) || !battle.participants.filter({ $0.pawn.isEqualTo(item: pawn) }).isEmpty {
                return true
            }
        }
        return false
    }
}

// MARK: Turns
extension StrategyGridStore {
    
    private func observeTurnOutput(_ output: GDLassoStore<TurnManagementModule>.Output) {
        switch output {
        case .didStartTurn(let faction):
            let pawnsToActivate = state.gridMap.pawnNodes.filter { $0.faction == faction && !isPawnInBattle($0) }
            
            // If no active pawns then end the turn, eventually this should probably allow the pawns-in-battle a chance to do aux actions (use item, etc.)
            if pawnsToActivate.isEmpty {
                log("no active pawns, ending turn automatically.")
                turnStore.dispatchExternalAction(.endTurn)
            } else {
                // On turn start refresh action pool and automatically select the first pawn
                let activePool = FactionActionPool(pawns: pawnsToActivate)
                update { state in
                    state.activeActionPool = activePool
                    state.selectedPawn = pawnsToActivate.first
                }
            }
        case .didEndTurn(let faction):
            log("did end turn")
        case .didStartRound:
            log("did start round")
        case .didEndRound:
            let battles = state.stagedBattles
            update { $0.stagedBattles = [:] }
            dispatchOutput(.didEndRoundWithBattles(Array(battles.values)))
        }
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
        case .support, .attack:
            guard let targetPawn = state.gridMap.getPawnAtIndex(cellIndex) else { return }
            addParticipantToBattle(at: cellIndex, targetPawn: targetPawn, actingPawn: actingPawn, actingIndex: pawnIndex)
            update { $0.activeActionPool?.exhaust(pawn: actingPawn) }
        case .endTurn:
            update { $0.activeActionPool?.exhaust(pawn: actingPawn) }
        case .compoundAction(let first, let second):
            await execute(action: first, actingPawn: actingPawn, targetCell: targetCell)
            await execute(action: second, actingPawn: actingPawn, targetCell: targetCell)
        }
        
        // Exhaust action
        update { state in
            do {
                if case .compoundAction = action {
                    log("Compound action complete, no action exhaustion needed.")
                } else {
                    try state.activeActionPool?.exhaust(action: action, for: actingPawn)
                    log("Exhausted pawn's \(action.title) action")
                }
            } catch {
                log("Failed to exhaust pawn's \(action.title) action with error: \(error)")
            }
        }
    }
    
    /// Moves the given pawn to the given cell asynchronously
    @MainActor
    private func executeMove(actingPawn: any StrategyGridPawn, targetCell: StrategyGridCell) async {
        guard let pawnIndex = state.gridMap.getIndexFor(pawn: actingPawn), 
              let cellIndex = state.gridMap.getIndexFor(cell: targetCell)
        else { return }
        
        let pathfinder = AStarPathfinder()
        let startNode = SimplePathNode(index: pawnIndex)
        let endNode = SimplePathNode(index: cellIndex)
        var nodes = state.gridMap.unoccupiedPathNodes + [startNode]
        
        // this and the check after the path is silly, find a better way
        if state.gridMap.isCellOccupied(targetCell) {
            nodes += [endNode]
        }
        
        guard var path = pathfinder.findPath(in: nodes, startNode: startNode, endNode: endNode) else { return }
        
        if state.gridMap.isCellOccupied(targetCell) {
            path.nodes = path.nodes.dropLast()
        }
        
        let globalSteps = path.nodes.compactMap { state.gridMap.getCellAtIndex($0.index)?._globalPosition }
        await actingPawn.move(along: GlobalPath(steps: globalSteps))
        
        update { state in
            do {
                let restingIndex = path.nodes.last?.index ?? cellIndex
                try state.gridMap.setPawnIndex(pawn: actingPawn, index: restingIndex)
            } catch {
                log("failed to set pawn's index after moving with error: \(error)")
            }
        }
    }
    
    func addParticipantToBattle(at index: GridIndex, targetPawn: any StrategyGridPawn, actingPawn: any StrategyGridPawn, actingIndex: GridIndex) {
        guard let direction = GridIndex.Direction.allCases.first(where: { actingIndex == index + $0.value }) else {
            log("Attempted to add participant to a non-neighboring battle.")
            return
        }
        
        let actionType: StagedBattle.Participant.ActionType = targetPawn.faction == actingPawn.faction ? .support : .attack
        let participant = StagedBattle.Participant(pawn: actingPawn, direction: direction, actionType: actionType)
        
        if var existingBattle = state.stagedBattles[index] {
            do {
                try existingBattle.addParticipant(participant)
                update { $0.stagedBattles[index] = existingBattle }
                log("added participant to existing staged battle")
            } catch {
                log("failed to participant to existing staged battle with error: \(error)")
            }
        } else {
            let newBattle = StagedBattle(targetPawn: targetPawn, initialParticipant: participant)
            update { $0.stagedBattles[index] = newBattle }
            log("added new staged battle")
        }
    }
}

// MARK: Cell Selection
extension StrategyGridStore {

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
        } else {
            log("Did click empty cell, no selected pawn")
        }
    }
    
    private func handleDidSelectOccupiedCell(_ cell: StrategyGridCell, occupant: any StrategyGridPawn) {
        update { $0.selectedCell = cell }
        
        if let selectedPawn = state.selectedPawn {
            update { $0.selectedCell = cell }
        } else if occupant.faction == state.activeFaction {
            log("No active pawn. Selected active pawn")
            update { $0.selectedPawn = occupant }
        } else {
            log("No active pawn. Selected inactive pawn of faction: \(occupant.faction). Active faction is \(state.activeFaction)")
        }
    }
}
