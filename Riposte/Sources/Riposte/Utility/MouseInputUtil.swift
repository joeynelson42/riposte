//
//  MouseInputUtil.swift
//
//
//  Created by Joey Nelson on 5/4/24.
//

import Foundation
import SwiftGodot

enum MouseInputUtil {
    enum MouseInputError: Error, CustomStringConvertible {
        case noCamera, noMousePosition
        
        var description: String {
            switch self {
            case .noCamera: return "No camera found."
            case .noMousePosition: return "No mouse position found."
            }
        }
    }
    
    static func getNodeAtMousePosition(from sourceNode: Node3D) throws -> Node3D? {
        guard let camera = sourceNode.getViewport()?.getCamera3d() else { throw MouseInputError.noCamera }
        guard let mousePosition = sourceNode.getViewport()?.getMousePosition() else { throw MouseInputError.noMousePosition }
        
        let rayStart = camera.projectRayOrigin(screenPoint: mousePosition)
        let rayEnd = rayStart + camera.projectRayNormal(screenPoint: mousePosition) * 2000
        let rayQuery = PhysicsRayQueryParameters3D.create(from: rayStart, to: rayEnd, collisionMask: 0b0001)

        guard let result = sourceNode.getWorld3d()?.directSpaceState?.intersectRay(parameters: rayQuery),
              let collider = result["collider"],
              let node = Node3D.makeOrUnwrap(collider)
        else { return nil }
        
        return node
    }
}
