//
//  InputReceiver.swift
//
//
//  Created by Joey Nelson on 5/12/24.
//

import Foundation
import GDLasso
import SwiftGodot

@Godot
class InputReceiver: Node3D, SceneNode {
    
    var store: InputReceiverModule.NodeStore?
    
    override func _input(event: InputEvent) {
        if event is InputEventMouseButton {
            dispatchInternalAction(.didReceiveInput(.mouseClick(event)))
        } else if event is InputEventMouseMotion {
            dispatchInternalAction(.didReceiveInput(.mouseMotion(event)))
        } else if event.isAction("move_up") {
            dispatchInternalAction(.didReceiveInput(.move(direction: .up, event)))
        } else if event.isAction("move_down") {
            dispatchInternalAction(.didReceiveInput(.move(direction: .down, event)))
        } else if event.isAction("move_left") {
            dispatchInternalAction(.didReceiveInput(.move(direction: .left, event)))
        } else if event.isAction("move_right") {
            dispatchInternalAction(.didReceiveInput(.move(direction: .right, event)))
        }
    }
    
}
