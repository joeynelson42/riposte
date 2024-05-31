//
//  GloballyPositioned.swift
//  
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation
import SwiftGodot

protocol GloballyPositioned {
    var _globalPosition: Vector3 { get }
    
    func setGlobalPosition(_ position: Vector3)
}

extension GloballyPositioned where Self:Node3D {
    var _globalPosition: Vector3 { return globalPosition }
    
    func setGlobalPosition(_ position: Vector3) {
        globalPosition = position
    }
}
