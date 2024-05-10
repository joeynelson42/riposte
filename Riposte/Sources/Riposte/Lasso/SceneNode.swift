//
//  SceneNode.swift
//
//
//  Created by Joey Nelson on 5/10/24.
//

import Foundation
import SwiftGodot

//@Godot
//class SceneNode<Module: SceneModule>: Node3D {
//    var store: SceneStore<Module>?
//}

protocol SceneNode {
    associatedtype Store: AbstractSceneStore
}
