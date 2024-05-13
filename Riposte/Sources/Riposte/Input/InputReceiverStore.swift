//
//  InputReceiverStore.swift
//
//
//  Created by Joey Nelson on 5/12/24.
//

import Foundation
import GDLasso
import SwiftGodot

class InputReceiverStore: GDLassoStore<InputReceiverModule> {
    
    override func handleAction(_ internalAction: GDLassoStore<InputReceiverModule>.InternalAction) {
        switch internalAction {
        case .didReceiveInput(let inputType):
            dispatchOutput(.didReceiveInput(inputType))
        }
    }
    
}
