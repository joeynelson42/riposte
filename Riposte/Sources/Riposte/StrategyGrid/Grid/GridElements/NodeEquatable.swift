//
//  NodeEquatable.swift
//
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation

protocol NodeEquatable {
    
    var id: ObjectIdentifier { get }
    
    func isEqualTo(item: NodeEquatable) -> Bool
}

extension NodeEquatable {
    func isEqualTo(item: NodeEquatable) -> Bool {
        return item.id == self.id
    }
}
