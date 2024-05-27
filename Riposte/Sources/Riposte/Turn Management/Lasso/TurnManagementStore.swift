//
//  TurnManagementStore.swift
//
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation
import GDLasso

class TurnManagementStore: GDLassoStore<TurnManagementModule> {
    
    override func handleAction(_ externalAction: GDLassoStore<TurnManagementModule>.ExternalAction) {
        switch externalAction {
        case .endTurn:
            break
        }
    }
    
}
