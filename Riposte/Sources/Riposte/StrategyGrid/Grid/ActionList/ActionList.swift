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

            if actions.isEmpty{
                hide()
                return
            } else {
                show()
            }
            
            for action in actions {
                self.list?.addItem(text: action.title)
            }
            
            self.list?.addItem(text: "Cancel")
        }
        
        list?.itemSelected.connect({ index in
            store.dispatchInternalAction(.didSelectItem(index: Int(index)))
        })
        
//        list?.itemClicked.connect({ index,_,_ in
//            store.dispatchInternalAction(.didSelectItem(index: Int(index)))
//        })
    }
}
