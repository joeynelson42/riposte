//
//  InputReceiverModule.swift
//
//
//  Created by Joey Nelson on 5/12/24.
//

import Foundation
import GDLasso
import SwiftGodot

typealias InputType = InputReceiverModule.InputType

struct InputReceiverModule: SceneModule {
    
    enum InputType {
        enum MovementDirection {
            case up, down, left, right
        }
        
        case mouseClick(InputEvent)
        case mouseMotion(InputEvent)
        case move(direction: MovementDirection, InputEvent)
    }
    
    enum InternalAction {
        case didReceiveInput(InputType)
    }
    
    enum Output {
        case didReceiveInput(InputType)
    }
}
