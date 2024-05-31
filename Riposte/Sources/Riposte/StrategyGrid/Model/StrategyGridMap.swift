//
//  StrategyGridMap.swift
//
//
//  Created by Joey Nelson on 5/13/24.
//

import Foundation
import SwiftGodot

/// Stores the indices of a StrategyGrid's cells and pawns and provides a plethora of data access methods
///
/// TODO: Lots of room for formalization and caching
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
    
    var unoccupiedPathNodes: [any PathNode] { unoccupiedCells.compactMap { getIndexFor(cell: $0) }.map { SimplePathNode(index: $0) } }
    
    var cellNodes: [StrategyGridCell] { Array(cells.values) }
    
    func getCellAtIndex(_ index: GridIndex) -> StrategyGridCell? {
        return cells[index]
    }
    
    func getIndexFor(cell: StrategyGridCell) -> GridIndex? {
        return cells.first(where: { $0.value.isEqualTo(item: cell) })?.key
    }
    
    var occupiedCells: [StrategyGridCell] { cellNodes.filter { isCellOccupied($0) } }
    
    var unoccupiedCells: [StrategyGridCell] { cellNodes.filter { !isCellOccupied($0) } }
    
    func isCellOccupied(_ cell: StrategyGridCell) -> Bool {
        guard let index = getIndexFor(cell: cell) else { return false }
        return getPawnAtIndex(index) != nil
    }
    
    func getNeighbors(of cell: StrategyGridCell) -> [StrategyGridCell] {
        guard let index = getIndexFor(cell: cell) else { return [] }
        
        let north = GridIndex(x: index.x, y: index.y + 1)
        let south = GridIndex(x: index.x, y: index.y - 1)
        let east = GridIndex(x: index.x + 1, y: index.y)
        let west = GridIndex(x: index.x - 1, y: index.y)
        
        let neighbors: [StrategyGridCell] = [north, south, east, west].compactMap { getCellAtIndex($0) }
        return neighbors
    }
    
    func areNeighborsOccupied(cell: StrategyGridCell) -> Bool {
        guard let index = getIndexFor(cell: cell) else { return false }
        let neighbors = getNeighbors(of: cell)
        return neighbors.reduce(false) { result, cell in
            return result && isCellOccupied(cell)
        }
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
