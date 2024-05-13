//
//  PawnMover.swift
//
//
//  Created by Joey Nelson on 5/13/24.
//

import Foundation
import SwiftGodot

protocol PawnMovable {
    associatedtype Mover: PawnMover
    
    var mover: Mover? { get set }
    
    func move(along path: GlobalPath) async
}

extension PawnMovable where Self:Node3D {
    func move(along path: GlobalPath) async {
        guard let mover else { return }
        return await mover.move(node: self, along: path)
    }
}

protocol PawnMover {
    func move(node: Node3D, along path: GlobalPath) async
}
