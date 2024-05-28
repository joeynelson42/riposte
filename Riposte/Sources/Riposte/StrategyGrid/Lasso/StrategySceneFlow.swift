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
    private let turnStore = TurnManagementStore(with: .init(factions: []))
    
    override func _ready() {
        turnStore.observeOutput(observeTurnOutput(_:))
        
        gridStore.observeOutput(observeGridOutput(_:))
        grid?.set(store: gridStore.asNodeStore())
        
        inputReceiver?.set(store: inputStore.asNodeStore())
        inputStore.observeOutput(observeInputReciverOutput(_:))
        
        super._ready()
    }
}

// MARK: Grid
extension StrategySceneFlow {
    private func observeGridOutput(_ output: GDLassoStore<StrategyGridModule>.Output) {
        switch output {
        case .didInitializeGrid(let gridMap):
            let factions = Set(gridMap.pawnNodes.map { $0.faction })
            GD.print("did init grid, initializing turn store, faction count: \(factions.count). pawn count: \(gridMap.pawnNodes.count)")
            turnStore.dispatchExternalAction(.initialize(Array(factions)))
        }
    }
}

// MARK: Input Receiving
extension StrategySceneFlow {
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
        gridStore.dispatchExternalAction(.input(.didClickCell(targetNode)))
    }
    
    private func handleMouseMotion(event: InputEvent) {
        guard let targetNode = try? MouseInputUtil.getNodeAtMousePosition(from: self) as? StrategyGridCell else { return }
        gridStore.dispatchExternalAction(.input(.didHoverCell(targetNode)))
    }
}

// MARK: Turn Management
extension StrategySceneFlow {
    private func observeTurnOutput(_ output: GDLassoStore<TurnManagementModule>.Output) {
        switch output {
        case .didStartTurn(let faction):
            gridStore.dispatchExternalAction(.turn(.didStartTurn(faction)))
            GD.print("did start turn, faction: \(faction)")
        case .didEndTurn(let faction):
            gridStore.dispatchExternalAction(.turn(.didEndTurn(faction)))
        case .didStartRound:
            break
        case .didEndRound:
            break
        }
    }
}
