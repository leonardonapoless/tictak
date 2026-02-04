import Foundation

struct Move {
    let player: Player
    let boardIndex: Int
    
    var indicator: String {
        player == .human ? "xmark" : "circle"
    }
}
