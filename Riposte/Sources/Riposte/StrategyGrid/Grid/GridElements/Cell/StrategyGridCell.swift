//
//  StrategyGridCell.swift
//  
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation

protocol StrategyGridCell: GloballyPositioned, NodeEquatable, WorldAware {
    func setPathIndicator(hidden: Bool)
}
