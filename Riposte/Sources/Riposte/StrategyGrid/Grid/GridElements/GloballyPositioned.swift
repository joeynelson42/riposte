//
//  GloballyPositioned.swift
//  
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation
import SwiftGodot

protocol GloballyPositioned {
    var globalPosition: Vector3 { get }
    
    func setGlobalPosition(_ position: Vector3)
}
