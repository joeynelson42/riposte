//
//  File.swift
//  
//
//  Created by Joey Nelson on 5/4/24.
//

import Foundation
import SwiftGodot

@Godot
class PlayerController: CharacterBody2D {
    var acceleration: Float = 200
    var friction: Double = 100
    var speed: Double = 300

    var movementVector: Vector2 {
        var movement = Vector2.zero
        let xInput = Input.getActionStrength(action: "move_right") - Input.getActionStrength(action: "move_left")
        let yInput = Input.getActionStrength(action: "move_down") - Input.getActionStrength(action: "move_up")
        movement.x = Float(xInput)
        movement.y = Float(yInput)
        return movement.normalized()
    }
    
    override func _physicsProcess(delta: Double) {
        if Engine.isEditorHint() { return }
        
        if movementVector != .zero {
            let acceleratedVector = Vector2(x: acceleration, y: acceleration)
            let acceleratedMovement = movementVector * acceleratedVector
            self.velocity = acceleratedMovement.limitLength(speed)
        } else {
            velocity = velocity.moveToward(to: .zero, delta: friction)
        }
        self.moveAndSlide()
        super._physicsProcess(delta: delta)
    }    
}
