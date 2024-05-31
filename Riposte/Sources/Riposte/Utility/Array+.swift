//
//  Array+.swift
//
//
//  Created by Joey Nelson on 5/31/24.
//

import Foundation

extension Array {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
