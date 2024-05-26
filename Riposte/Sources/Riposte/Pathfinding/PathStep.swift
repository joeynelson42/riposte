//
//  PathNode.swift
//
//
//  Created by Joey Nelson on 5/5/24.
//

import Foundation

protocol PathNode: Equatable{
    var index: GridIndex { get }
}

struct SimplePathNode: PathNode {
    var index: GridIndex
}
