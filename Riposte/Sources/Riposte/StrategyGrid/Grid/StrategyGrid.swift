//
//  StrategyGrid.swift
//
//
//  Created by Joey Nelson on 5/4/24.
//

import Foundation
import SwiftGodot
import GDLasso

@Godot
class StrategyGrid: Node3D, SceneNode {
    
    var store: StrategyGridModule.NodeStore?
    
    @SceneTree(path: "ActionList") private var actionList: ActionList?
    
    private var hasSnappedPawns: Bool = false
    
    private func updatePathIndicators() {
        guard let gridMap = state?.gridMap else { return }
        
        var visibleNodes = [StrategyGridCell]()
        
        if let hoveredCell = state?.hovered {
            visibleNodes.append(hoveredCell)
        }
        
        if let selectedPawn = state?.selectedPawn, 
           let pawnIndex = state?.gridMap.getIndexFor(pawn: selectedPawn),
           let cell = state?.gridMap.getCellAtIndex(pawnIndex) {
            visibleNodes.append(cell)
        }
        
        gridMap.cellNodes.forEach { node in
            node.setPathIndicator(hidden: !visibleNodes.contains( where: { $0.isEqualTo(item: node) }))
        }
    }
    
    func setUp(with store: StrategyGrid.NodeStore) {
        setUpGrid(with: store)
        setUpActionList(with: store)

        store.observeState(\.selectedPawn) { [weak self] _ in
            self?.updatePathIndicators()
        }
        
        store.observeState(\.gridMap) { [weak self] _ in
            if self?.hasSnappedPawns ?? false {
                self?.snapPawnsToGrid()
                self?.hasSnappedPawns = true
            }
        }

        store.observeState(\.hovered) { [weak self] _ in
            self?.updatePathIndicators()
        }
    }
    
    private func setUpGrid(with store: StrategyGrid.NodeStore) {
        let allCells: [any StrategyGridCell] = getChildren().compactMap { $0 as? any StrategyGridCell }
        let allPawns: [any StrategyGridPawn] = getChildren().compactMap { $0 as? any StrategyGridPawn }
        dispatchInternalAction(.onReady(gridCells: allCells, pawns: allPawns))
    }
    
    private func setUpActionList(with store: StrategyGrid.NodeStore) {
        let actionListStore = store.asNodeStore(
            for: ActionListNodeModule.self,
            stateMap: { ActionListNodeModule.NodeState(actions: $0.currentActions) },
            actionMap: { action in
                switch action {
                case .didSelectItem(let index):
                    return .actionList(.didSelectItem(index: index))
                }
            }
        )

        actionList?.set(store: actionListStore)
    }
    
    /// Moves pawns to the center of their corresponding grid cell on the x,z plane
    private func snapPawnsToGrid() {
        guard let gridMap = state?.gridMap else { return }
        for pawn in gridMap.pawnNodes {
            guard let index = gridMap.getIndexFor(pawn: pawn),
                  let cell = gridMap.getCellAtIndex(index)
            else { continue }
            
            let newPos = Vector3(x: cell.globalPosition.x, y: pawn.globalPosition.y, z: cell.globalPosition.z)
            pawn.setGlobalPosition(newPos)
        }
    }
}
