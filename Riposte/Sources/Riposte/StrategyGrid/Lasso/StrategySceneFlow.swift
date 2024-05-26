//
//  StrategySceneFlow.swift
//
//
//  Created by Joey Nelson on 5/10/24.
//

import Foundation
import SwiftGodot
import GDLasso

@Godot
class StrategySceneFlow: Node3D, SceneFlow {
    
    @SceneTree(path: "StrategyGrid") private var grid: StrategyGrid?
    @SceneTree(path: "InputReceiver") private var inputReceiver: InputReceiver?
    
    private let gridStore = StrategyGridStore(with: .init())
    private let inputStore = InputReceiverStore(with: .init())
    
    override func _ready() {
        grid?.set(store: gridStore.asNodeStore())
        
        if grid.isNull {
            GD.print("Grid is null.")
        }
        
        inputReceiver?.set(store: inputStore.asNodeStore())
        inputStore.observeOutput(observeInputReciverOutput(_:))
        
        super._ready()
    }
    
    private func observeInputReciverOutput(_ output: GDLassoStore<InputReceiverModule>.Output) {
        switch output {
        case .didReceiveInput(let inputType):
            switch inputType {
            case .mouseClick(let event):
                handleMouseClick(event: event)
            case .mouseMotion(let event):
                handleMouseMotion(event: event)
            case .move(direction: let direction, let event):
                GD.print(event.asText())
            }
        }
    }
    
    private func handleMouseClick(event: InputEvent) {
        guard event.isReleased(), let targetNode = try? MouseInputUtil.getNodeAtMousePosition(from: self) as? StrategyGridCell else { return }
        gridStore.dispatchExternalAction(.didClickCell(targetNode))
    }
    
    private func handleMouseMotion(event: InputEvent) {
        
    }
}
