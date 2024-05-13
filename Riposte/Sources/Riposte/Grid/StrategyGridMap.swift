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
    
    init(cells: [GridIndex : StrategyGridCellNode]) {
        self.cells = cells
    }
    
    init() {
        cells = [:]
    }
    
    var pathNodes: [PathNode] { cells.keys.map { StrategyGridCell(index: $0) } }
    
    var cellNodes: [StrategyGridCellNode] { Array(cells.values) }
    
    func getCellAtIndex(_ index: GridIndex) -> StrategyGridCellNode? {
        return cells[index]
    }
    
    func getIndexFor(cell: StrategyGridCellNode) -> GridIndex? {
        return cells.first(where: { $0.value == cell })?.key
    }
}
