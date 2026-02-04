//
//  SoundEffect.swift
//  tictak
//
//  Created by Leonardo Nápoles on 9/18/25.
//

import Foundation

enum SoundEffect {
    case playerMove
    case computerMove
    case playerWin
    case playerLose
    case draw
    
    var fileName: String {
        switch self {
        case .playerMove:
            return "player_move.aif"
        case .computerMove:
            return "computer_move.aif"
        case .playerWin:
            return "win.aif"
        case .playerLose:
            return "lose.aif"
        case .draw:
            return "draw.aif"
        }
    }
}
