//
//  ActionList.swift
//
//
//  Created by Joey Nelson on 5/27/24.
//

import Foundation
import SwiftGodot
import GDLasso

@Godot
final class ActionList: Control, SceneNode {
    
    var store: ActionListNodeModule.NodeStore?
    
    @SceneTree(path: "List") private var list: ItemList?
    
    func setUp(with store: ActionList.NodeStore) {
        store.observeState(\.actions) { [weak self] actions in
            guard let self else { return }
            self.list?.clear()

            for action in actions {
                self.list?.addItem(text: action)
            }
        }
        
        list?.itemSelected.connect({ index in
            store.dispatchInternalAction(.didSelectItem(index: Int(index)))
        })
        
        list?.itemClicked.connect({ index,_,_ in
            store.dispatchInternalAction(.didSelectItem(index: Int(index)))
        })
    }
}
