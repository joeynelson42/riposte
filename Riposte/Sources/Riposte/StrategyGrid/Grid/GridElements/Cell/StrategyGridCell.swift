//
//  StrategyGridCell.swift
//  
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation

enum StrategyGridCellIndicatorType {
    case none, move, attack, support, path, selection
}

protocol StrategyGridCell: GloballyPositioned, NodeEquatable, WorldAware {
    
    func showIndicator(type: StrategyGridCellIndicatorType)
    
    func hideIndicators()
    
}
