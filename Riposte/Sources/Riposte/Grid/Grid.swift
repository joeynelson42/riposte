//
//  Grid.swift
//
//
//  Created by Joey Nelson on 5/4/24.
//

import Foundation
import SwiftGodot

final class Grid: Node3D {
    
    private var cells: [GridCell] = []
    
    override func _ready() {
        self.cells = findCells()
        GD.print("found \(cells.count) cell(s)")
    }
    
    private func findCells() -> [GridCell] {
        return getChildren().compactMap { $0 as? GridCell }
    }
}
