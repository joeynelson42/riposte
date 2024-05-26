//
//  StrategyGridMap.swift
//
//
//  Created by Joey Nelson on 5/13/24.
//

import Foundation
import SwiftGodot

struct StrategyGridMap {
    private var cells: [GridIndex: StrategyGridCellNode]
    
    private var pawns: [GridIndex: any StrategyGridPawn]
    
    init(cells: [GridIndex : StrategyGridCellNode], pawns: [GridIndex: any StrategyGridPawn]) {
        self.cells = cells
        self.pawns = pawns
    }
    
    init() {
        cells = [:]
        pawns = [:]
    }
    
    // MARK: Cells
    var pathNodes: [PathNode] { cells.keys.map { StrategyGridCell(index: $0) } }
    
    var cellNodes: [StrategyGridCellNode] { Array(cells.values) }
    
    func getCellAtIndex(_ index: GridIndex) -> StrategyGridCellNode? {
        return cells[index]
    }
    
    func getIndexFor(cell: StrategyGridCellNode) -> GridIndex? {
        return cells.first(where: { $0.value == cell })?.key
    }
    
    // MARK: Pawns
    var pawnNodes: [any StrategyGridPawn] { Array(pawns.values) }
    
    func getPawnAtIndex(_ index: GridIndex) -> (any StrategyGridPawn)? {
        return pawns[index]
    }
    
    func getIndexFor(pawn: any StrategyGridPawn) -> GridIndex? {
        return pawns.first(where: { $0.value.isEqualTo(item: pawn) })?.key
    }
}
