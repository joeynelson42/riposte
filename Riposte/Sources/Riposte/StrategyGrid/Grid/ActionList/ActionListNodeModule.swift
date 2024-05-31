//
//  ActionListNodeModule.swift
//
//
//  Created by Joey Nelson on 5/27/24.
//

import Foundation
import SwiftGodot
import GDLasso

struct ActionListNodeModule: NodeModule {
    
    struct NodeState {
        var actions: [PawnAction]
    }
    
    enum NodeAction {
        case didSelectItem(index: Int)
    }
    
}
