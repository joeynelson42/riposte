//
//  NodeEquatable.swift
//
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation
import SwiftGodot

protocol NodeEquatable {
    
    var nodeEquatableID: String { get }
    
    func isEqualTo(item: NodeEquatable) -> Bool
}

extension NodeEquatable where Self: Node {
    var nodeEquatableID: String { "\(id)" }
}

extension NodeEquatable {
    func isEqualTo(item: NodeEquatable) -> Bool {
        return item.nodeEquatableID == self.nodeEquatableID
    }
}
