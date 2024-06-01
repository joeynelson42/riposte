//
//  StrategyGridMapTests.swift
//  
//
//  Created by Joey Nelson on 5/31/24.
//

import XCTest
@testable import SwiftGodot
@testable import Riposte

final class StrategyGridMapTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func test_init() {
        // Given
        let width = 5
        let length = 5
        
        // When
        let map = generateEmptyGridMap(width: width, length: length)
        
        // Then
        XCTAssertEqual(map.cellNodes.count, 25)
    }
    
    func test_addPawn() {
        // Given
        var map = generateEmptyGridMap(width: 5, length: 5)
        let pawnIndex = GridIndex(x: 0, y: 0)
        let pawn = MockPawn()
        
        // When
        XCTAssertTrue(map.occupiedCells.isEmpty)
        try? map.addPawn(pawn: pawn, at: pawnIndex)
        
        // Then
        XCTAssertEqual(map.getIndexFor(pawn: pawn), pawnIndex)
        XCTAssertFalse(map.occupiedCells.isEmpty)
    }
    
    func test_removePawn() {
        // Given
        var map = generateEmptyGridMap(width: 5, length: 5)
        let pawnIndex = GridIndex(x: 0, y: 0)
        let pawn = MockPawn()
        
        // When
        XCTAssertTrue(map.occupiedCells.isEmpty)
        try? map.addPawn(pawn: pawn, at: pawnIndex)
        XCTAssertFalse(map.occupiedCells.isEmpty)
        try? map.removePawn(at: pawnIndex)
        
        // Then
        XCTAssertNil(map.getPawnAtIndex(pawnIndex))
        XCTAssertTrue(map.occupiedCells.isEmpty)
    }
    
    func test_neighborOccupancy_whenSurrounded() {
        // Given
        var map = generateEmptyGridMap(width: 5, length: 5)
        let targetPawnIndex = GridIndex(x: 1, y: 1)
        try? map.addPawn(pawn: MockPawn(), at: targetPawnIndex)
        
        // When
        targetPawnIndex.neighboringIndices.forEach { 
            try? map.addPawn(pawn: MockPawn(), at: $0)
        }
                
        // Then
        guard let cell = map.getCellAtIndex(targetPawnIndex) else {
            XCTFail("No cell found")
            return
        }
        XCTAssertTrue(map.areNeighborsOccupied(cell: cell))
    }
}

fileprivate extension StrategyGridMapTests {
    
    func generateEmptyGridMap(width: Int, length: Int) -> StrategyGridMap {
        let indices = generateGridIndices(width: width, length: length)
        let cells = generateCells(indices: indices)
        return StrategyGridMap(cells: cells, pawns: [:])
    }
    
    func generateGridIndices(width: Int, length: Int) -> [GridIndex] {
        guard width > 0, length > 0 else { return [] }
        
        var indices = [GridIndex]()
        for x in 0..<width {
            for y in 0..<length {
                indices.append(GridIndex(x: x, y: y))
            }
        }
        return indices
    }
    
    func generateCells(indices: [GridIndex]) -> [GridIndex: StrategyGridCell] {
        indices.reduce(into: [GridIndex: StrategyGridCell](), {  $0[$1] = MockCell() })
    }
}

fileprivate class MockPawn: StrategyGridPawn {
    var moveDistance: Int = 5
    
    var mover: SnapPawnMover = SnapPawnMover()
    
    var faction: Faction
    
    func move(along path: GlobalPath) async {}
    
    var _globalPosition: Vector3 { return internalGlobalPosition }
    
    private var internalGlobalPosition = Vector3()
    
    func setGlobalPosition(_ position: Vector3) {
        internalGlobalPosition = position
    }
    
    var nodeEquatableID: String
    
    init(id: String = UUID().uuidString, faction: Faction = .unknown) {
        self.nodeEquatableID = id
        self.faction = faction
    }
}

fileprivate class MockCell: StrategyGridCell {
    func showIndicator(type: StrategyGridCellIndicatorType) {
        currentIndicator = type
    }
    
    func hideIndicators() {
        currentIndicator = nil
    }
    
    private var currentIndicator: StrategyGridCellIndicatorType?
    
    var _globalPosition: Vector3 { return internalGlobalPosition }
    
    private var internalGlobalPosition = Vector3()
    
    func setGlobalPosition(_ position: Vector3) {
        internalGlobalPosition = position
    }
    
    var nodeEquatableID: String
    
    var world3D: World3D?
    
    init(id: String = UUID().uuidString) {
        self.nodeEquatableID = id
    }
}
