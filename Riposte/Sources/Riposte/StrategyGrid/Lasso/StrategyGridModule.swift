//
//  StrategyGridModule.swift
//  
//
//  Created by Joey Nelson on 5/10/24.
//

import Foundation
import SwiftGodot
import GDLasso

struct StrategyGridModule: SceneModule {
    
    struct State {
        var gridMap = StrategyGridMap()
        
        var selectedPawn: (any StrategyGridPawn)?
        var selectedAction: PawnAction?
        var selectedCell: StrategyGridCell?
        
        var currentActions: [PawnAction] {
            guard let selectedCell, let cellIndex = gridMap.getIndexFor(cell: selectedCell), let actions = actionMap[cellIndex] else { return [] }
            return actions
        }
        
        var activeFaction: Faction = .unknown
        var activePawns: [any StrategyGridPawn] = []
        
        var activeActionPool: FactionActionPool?
        
        var actionMap: [GridIndex: [PawnAction]] {
            guard let activeActionPool, let selectedPawn else { return [:] }
            let availableActions = activeActionPool.getPawnActions(selectedPawn)
            return ActionEvaluation.getPossibleActions(for: selectedPawn, on: gridMap, availableActions: availableActions)
        }
        
        var hovered: StrategyGridCell?
        var hoveredPath: Path?        
    }
    
    enum ExternalAction {
        enum Input {
            case didClickCell(StrategyGridCell)
            case didHoverCell(StrategyGridCell)
            case didEndHovering
        }
        case input(Input)
        
        enum Turn {
            case didEndTurn(Faction)
            case didStartTurn(Faction)
        }
        case turn(Turn)
    }
    
    enum InternalAction {
        case onReady(gridCells: [StrategyGridCell], pawns: [any StrategyGridPawn])
        
        enum ActionList {
            case didSelectItem(index: Int)
        }
        case actionList(ActionList)
    }
    
    enum Output {
        case didInitializeGrid(StrategyGridMap)
        case didExhaustAllActivePawns
    }
}

// Temp solution
struct ActionEvaluation {
    
    static func getPossibleActions(for pawn: any StrategyGridPawn, on map: StrategyGridMap, availableActions: [PawnAction]) -> [GridIndex: [PawnAction]] {
        guard let pawnIndex = map.getIndexFor(pawn: pawn) else { return [:] }
        
        let pathfinder = AStarPathfinder()
        
        var gridActions = [GridIndex: [PawnAction]]()
        for cell in map.cellNodes {
            guard let cellIndex = map.getIndexFor(cell: cell) else { continue }
            gridActions[cellIndex] = []
            
            // If we're looking at the pawn's own cell the only action to take is endTurn.
            if cellIndex == pawnIndex {
                gridActions[cellIndex]?.append(.endTurn)
                continue
            }
            
            // Find path to cell
            let cellOccupant = map.getPawnAtIndex(cellIndex)
            var potentialPathNodes = map.unoccupiedPathNodes
            potentialPathNodes.append(SimplePathNode(index: pawnIndex))
            if cellOccupant != nil {
                potentialPathNodes.append(SimplePathNode(index: cellIndex))
            }
            guard let path = pathfinder.findPath(in: potentialPathNodes, startNode: SimplePathNode(index: pawnIndex), endNode: SimplePathNode(index: cellIndex)) else { continue }
            
            // If distance to cell is greater than move distance there's nothing we can do there
            if pawn.moveDistance < path.nodes.count - 1 {
                continue
            }
            
            var isNeighboringCell = path.nodes.count == 2
            
            if let cellOccupant {
                if cellOccupant.faction == pawn.faction {
                    gridActions[cellIndex]?.append(isNeighboringCell ? .support : .compoundAction(.move, .support))
                } else {
                    gridActions[cellIndex]?.append(isNeighboringCell ? .attack : .compoundAction(.move, .attack))
                }
            } else {
                gridActions[cellIndex]?.append(.move)
            }
        }
        
        return gridActions
    }
    
}
