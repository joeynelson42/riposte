//
//  StrategyGridCellData.swift
//
//
//  Created by Joey Nelson on 5/4/24.
//

import Foundation

struct GridIndex: Hashable {
    var x: Int
    var y: Int
}

struct StrategyGridCellData: Equatable {
    var index: GridIndex
}
