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
    
    private func updatePathIndicators() {
        guard let gridMap = state?.gridMap else { return }
        
        var visibleNodes = [StrategyGridCell]()
        if let start = state?.start, let node = gridMap.getCellAtIndex(start) {
            visibleNodes.append(node)
        }
        
        if let end = state?.end, let node = gridMap.getCellAtIndex(end) {
            visibleNodes.append(node)
        }
        
        if let path = state?.currentPath {
            let pathNodes = path.nodes.compactMap { gridMap.getCellAtIndex($0.index) }
            visibleNodes.append(contentsOf: pathNodes)
        }
        
        gridMap.cellNodes.forEach { node in
            node.setPathIndicator(hidden: !visibleNodes.contains( where: { $0.isEqualTo(item: node) }))
        }
    }
    
    func setUpObservations() {
        let allCells: [any StrategyGridCell] = getChildren().compactMap { $0 as? StrategyGridCell }
        let allPawns: [any StrategyGridPawn] = getChildren().compactMap { $0 as? any StrategyGridPawn }
        
        dispatchInternalAction(.onReady(gridCells: allCells, pawns: allPawns))
        
        store?.observeState(\.start, handler: { [weak self] index in
            self?.updatePathIndicators()
        })
        
        store?.observeState(\.end, handler: { [weak self] index in
            self?.updatePathIndicators()
        })
        
        store?.observeState(\.currentPath, handler: { [weak self] index in
            self?.updatePathIndicators()
        })
        
        store?.observeState(\.gridMap, handler: { [weak self] _ in
            self?.snapPawnsToGrid()
        })
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
