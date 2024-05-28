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
        
//        if let start = state?.start, let node = gridMap.getCellAtIndex(start) {
//            visibleNodes.append(node)
//        }
//        
//        if let end = state?.end, let node = gridMap.getCellAtIndex(end) {
//            visibleNodes.append(node)
//        } else 
        if let hoveredCell = state?.hovered {
            visibleNodes.append(hoveredCell)
        }
//        
//        if let path = state?.currentPath {
//            let pathNodes = path.nodes.compactMap { gridMap.getCellAtIndex($0.index) }
//            visibleNodes.append(contentsOf: pathNodes)
//        } else if let hoveredPath = state?.hoveredPath {
//            let pathNodes = hoveredPath.nodes.compactMap { gridMap.getCellAtIndex($0.index) }
//            visibleNodes.append(contentsOf: pathNodes)
//        }
        
        gridMap.cellNodes.forEach { node in
            node.setPathIndicator(hidden: !visibleNodes.contains( where: { $0.isEqualTo(item: node) }))
        }
    }
    
    func setUp(with store: StrategyGrid.NodeStore) {
        setUpGrid(with: store)
        setUpActionList(with: store)

//        store.observeState(\.start) { [weak self] index in
//            self?.updatePathIndicators()
//        }
//
//        store.observeState(\.end) { [weak self] index in
//            self?.updatePathIndicators()
//        }
//
//        store.observeState(\.currentPath) { [weak self] index in
//            self?.updatePathIndicators()
//        }

        store.observeState(\.gridMap) { [weak self] _ in
            if self?.hasSnappedPawns ?? false {
                self?.snapPawnsToGrid()
                self?.hasSnappedPawns = true
            }
        }

        store.observeState(\.hovered) { oldValue, newValue in
            oldValue??.setPathIndicator(hidden: true)
            newValue?.setPathIndicator(hidden: false)
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
