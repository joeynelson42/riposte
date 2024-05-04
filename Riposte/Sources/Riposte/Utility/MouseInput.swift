//
//  MouseInput.swift
//
//
//  Created by Joey Nelson on 5/4/24.
//

import Foundation
import SwiftGodot

/*
 func mouse_point_to_world_space() -> Vector3:
     var spaceState = get_tree().root.get_world_3d().direct_space_state
     var mousePos = get_viewport().get_mouse_position()
     var camera = get_tree().root.get_camera_3d()
     var rayStart = camera.project_ray_origin(mousePos)
     var rayEnd = rayStart + camera.project_ray_normal(mousePos) * 2000
     var rayParams = PhysicsRayQueryParameters3D.create(rayStart, rayEnd, 0b0001)
     var rayResult = spaceState.intersect_ray(rayParams)
     if rayResult.has("position"):
         var pos = rayResult["position"] as Vector3
         return pos
     else:
         return Vector3()
 */

@Godot
class MouseInput: Node3D {
    @Export(.nodeType, "Camera3D")
    var camera: Camera3D? = nil
    
    override func _ready() {
        
    }
    
    override func _input(event: InputEvent) {
        guard let mouseEvent = event as? InputEventMouse,
              let targetNode = findNodeAtMousePosition(mouseEvent.globalPosition)
        else { return }
        
        switch event {
        case is InputEventMouseButton:
            GD.print(targetNode.position)
        case is InputEventMouseMotion:
            break
        default:
            return
        }
    }
    
    private func findNodeAtMousePosition(_ mousePosition: Vector2) -> Node3D? {
        guard let camera else {
            GD.print("findNodeAtMousePosition :: No camera found.")
            return nil
        }
        
        
        
        let ray = RayCast3D()
        let rayStart = camera.projectRayOrigin(screenPoint: mousePosition)
        let rayEnd = rayStart + camera.projectRayNormal(screenPoint: mousePosition) * 2000
        
//        PhysicsRayQueryParameters3D.create(from: rayStart, to: rayEnd)
        
        GD.print("ray start: \(rayStart)")
        GD.print("ray end: \(rayEnd)")
        
        ray.position = rayStart
        ray.targetPosition = rayEnd

        return ray.getCollider() as? Node3D
    }
}
