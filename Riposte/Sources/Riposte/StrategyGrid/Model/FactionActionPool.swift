//
//  FactionActionPool.swift
//
//
//  Created by Joey Nelson on 5/31/24.
//

import Foundation

struct FactionActionPool {
    
    private typealias ActionPool = [String: [PawnAction]]
    
    enum FactionActionPoolError: Error {
        case actionUnavailable
    }
    
    var pawns: [any StrategyGridPawn]
    
    /// Active pawns are those with any actions remaining
    var activePawns: [any StrategyGridPawn] { pawns.filter { !(actionPool[$0.nodeEquatableID]?.isEmpty ?? true) } }
    
    private var actionPool: ActionPool
    private let poolQueue = DispatchQueue(label: "action-pool-sync-queue", target: .global())
    
    init(pawns: [any StrategyGridPawn]) {
        self.pawns = pawns
        actionPool = pawns.reduce(into: [String: [PawnAction]](), { $0[$1.nodeEquatableID] = [.move, .attack, .support] })
    }
    
    public mutating func exhaust(action: PawnAction, for pawn: any StrategyGridPawn) throws {
        var actions = getPawnActions(pawn)
        guard let actionIndex = actions.firstIndex(of: action) else { throw FactionActionPoolError.actionUnavailable }
        actions.remove(at: actionIndex)
        var newPool = actionPool
        newPool[pawn.nodeEquatableID] = actions.isEmpty ? nil : actions
        update(actionPool: newPool)
    }
    
    public mutating func exhaust(pawn: any StrategyGridPawn) {
        actionPool[pawn.nodeEquatableID] = nil
    }
    
    public func getPawnActions(_ pawn: any StrategyGridPawn) -> [PawnAction] {
        return actionPool[pawn.nodeEquatableID] ?? []
    }
    
    public var isPoolExhausted: Bool { pawns.reduce(true, { $0 && getPawnActions($1).isEmpty }) }
    
    private mutating func update(actionPool: ActionPool) {
        poolQueue.sync {
            self.actionPool = actionPool            
        }
    }
}
