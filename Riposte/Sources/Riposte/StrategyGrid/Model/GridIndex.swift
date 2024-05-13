//
//  GridIndex.swift
//
//
//  Created by Joey Nelson on 5/5/24.
//

import Foundation

struct GridIndex: Hashable {
    
    enum Direction: CaseIterable {
        case up, down, left, right
        
        var value: GridIndex {
            switch self {
            case .up:
                return .init(x: 0, y: 1)
            case .down:
                return .init(x: 0, y: -1)
            case .left:
                return .init(x: -1, y: 0)
            case .right:
                return .init(x: 1, y: 0)
            }
        }
    }
    
    var x: Int
    var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init() {
        x = 0
        y = 0
    }
    
    static func +(lhs: GridIndex, rhs: GridIndex) -> GridIndex {
        return GridIndex(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
