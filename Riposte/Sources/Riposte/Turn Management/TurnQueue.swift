//
//  TurnQueue.swift
//  
//
//  Created by Joey Nelson on 5/26/24.
//

import Foundation

class TurnQueue {
    
    enum TurnQueueError: Error {
        case queueIsExhausted
    }
    
    // Public
    public let factionOrder: [Faction]
    
    public var activeFaction: Faction? { return activeQueue.first }
    
    public var isQueueExhausted: Bool { return activeQueue.isEmpty }
    
    // Private
    private var activeQueue: [Faction]
    
    private var exhaustedQueue: [Faction] = []
    
    init(factionOrder: [Faction]) {
        self.factionOrder = factionOrder
        self.activeQueue = factionOrder
    }
    
    func endTurn() throws {
        guard !isQueueExhausted else { throw TurnQueueError.queueIsExhausted }
        exhaustedQueue.append(activeQueue.removeFirst())
    }
}
