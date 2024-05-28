//
//  StrategyGridMap.swift
//
//
//  Created by Joey Nelson on 5/13/24.
//

import Foundation
import SwiftGodot

struct StrategyGridMap {
    
    enum MapError: Error {
        case pawnDoesNotExist
        case indexIsNotEmpty
    }
    
    private var cells: [GridIndex: StrategyGridCell]
    
    private var pawns: [GridIndex: any StrategyGridPawn]
    
    init(cells: [GridIndex : StrategyGridCell], pawns: [GridIndex: any StrategyGridPawn]) {
        self.cells = cells
        self.pawns = pawns
    }
    
    init() {
        cells = [:]
        pawns = [:]
    }
    
    // MARK: Cells
    var pathNodes: [any PathNode] { cells.keys.map { SimplePathNode(index: $0) } }
    
    var cellNodes: [StrategyGridCell] { Array(cells.values) }
    
    func getCellAtIndex(_ index: GridIndex) -> StrategyGridCell? {
        return cells[index]
    }
    
    func getIndexFor(cell: StrategyGridCell) -> GridIndex? {
        return cells.first(where: { $0.value.isEqualTo(item: cell) })?.key
    }
    
    // MARK: Pawns
    var pawnNodes: [any StrategyGridPawn] { Array(pawns.values) }
    
    func getPawnAtIndex(_ index: GridIndex) -> (any StrategyGridPawn)? {
        return pawns[index]
    }
    
    func getIndexFor(pawn: any StrategyGridPawn) -> GridIndex? {
        return pawns.first(where: { $0.value.isEqualTo(item: pawn) })?.key
    }
    
    mutating func setPawnIndex(pawn: any StrategyGridPawn, index: GridIndex) throws {
        // Verify pawn exists
        guard let currentIndex = getIndexFor(pawn: pawn) else {
            throw MapError.pawnDoesNotExist
        }
        
        // Verify index is empty
        guard getPawnAtIndex(index) == nil else {
            throw MapError.indexIsNotEmpty
        }
        
        // Move pawn to index
        pawns[currentIndex] = nil
        pawns[index] = pawn
    }
}
