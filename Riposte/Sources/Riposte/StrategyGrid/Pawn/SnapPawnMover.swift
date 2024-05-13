//
//  SnapPawnMover.swift
//
//
//  Created by Joey Nelson on 5/13/24.
//

import Foundation
import SwiftGodot


class SnapPawnMover: PawnMover {
    
    private var currentMoveTask: Task<Void, Error>?
    
    private var remainingPath: GlobalPath?
    
    @MainActor
    func move(node: Node3D, along path: GlobalPath) async {
        let group = DispatchGroup()
        for step in path.steps {
            group.enter()
            await move(node: node, to: step)
            group.leave()
        }
    }
    
    @MainActor
    private func move(node: Node3D, to step: Vector3) async {
        node.globalPosition = Vector3(x: step.x, y: node.globalPosition.y, z: step.z)
        try? await Task.sleep(nanoseconds: 250_000_000)
    }
}
