//
//  SceneStore.swift
//  
//
//  Created by Joey Nelson on 5/10/24.
//

import Foundation
import SwiftGodot

public protocol ActionDispatchable: AnyObject {
    associatedtype Action
    
    func dispatchAction(_ action: Action)
}

protocol StateObservable: AnyObject {
    associatedtype State
    
    var state: State { get }

    func observeState<Value>(_ keyPath: WritableKeyPath<State, Value>, handler: @escaping (_ oldValue: Value?, _ newValue: Value) -> Void)
}

protocol AbstractSceneStore: StateObservable, ActionDispatchable { }

class SceneStore<Module: SceneModule>: AbstractSceneStore {
    
    typealias State = Module.State
    typealias Action = Module.Action
    typealias Output = Module.Output
    
    private var stateBinder: ValueBinder<State>
    private var pendingUpdates: [Update<State>] = []
    private let queue = DispatchQueue(label: "lasso-store-sync-queue", target: .global())
    
    required init(with initialState: State) {
        self.stateBinder = ValueBinder(initialState)
    }
    
    public var state: State {
        return stateBinder.value
    }
    
    func dispatchAction(_ action: Action) {
        handleAction(action)
    }
    
    func handleAction(_ action: Action) {
        GD.print("handleAction not implemented.")
    }
    
    func observeState<Value>(_ keyPath: WritableKeyPath<Module.State, Value>, handler: @escaping (Value?, Value) -> Void) {
        stateBinder.bind(keyPath, to: handler)
    }
    
    // updates
        
    public typealias Update<T> = (inout T) -> Void
    
    public func update(_ update: @escaping Update<State> = { _ in return }) {
        updateState(using: update, apply: true)
    }
    
    public func batchUpdate(_ update: @escaping Update<State>) {
        updateState(using: update, apply: false)
    }
    
    private func updateState(using update: @escaping Update<State>, apply: Bool) {
        var newState: State?
        var pendingUpdates: [Update<State>]?
        queue.sync {
            self.pendingUpdates.append(update)
            if apply {
                pendingUpdates = self.pendingUpdates
                self.pendingUpdates = []
            }
        }
        if let pendingUpdates = pendingUpdates {
            newState = pendingUpdates.reduce(into: state) { state, update in
                update(&state)
            }
        }
        if let newState = newState {
            stateBinder.set(newState)
        }
    }
}
