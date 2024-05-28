//
//  SnapPawnMover.swift
//
//
//  Created by Joey Nelson on 5/13/24.
//

import Foundation
import SwiftGodot

class SnapPawnMover: PawnMover {
    
    var snapDelay: UInt64
    
    init(snapDelay: UInt64 = 250_000_000) {
        self.snapDelay = snapDelay
    }
    
    private var currentMoveTask: Task<Void, Error>?
    
    private var remainingPath: GlobalPath?
    
    @MainActor
    func move(node: CharacterBody3D, along path: GlobalPath) async {
        let group = DispatchGroup()
        for step in path.steps {
            group.enter()
            await move(node: node, to: step)
            group.leave()
        }
    }
    
    @MainActor
    private func move(node: CharacterBody3D, to step: Vector3) async {
        node.globalPosition = Vector3(x: step.x, y: node.globalPosition.y, z: step.z)
        log("Moved pawn to \(step)")
        try? await Task.sleep(nanoseconds: snapDelay)
    }
}
