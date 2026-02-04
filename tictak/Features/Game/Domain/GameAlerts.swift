import Foundation

struct AlertItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var message: String
    var buttonTitle: String
}

struct AlertContext {
    static let humanWin    = AlertItem(title: "You Win!",
                                       message: "You did a great job!",
                                       buttonTitle: "Play Again")
    
    static let computerWin = AlertItem(title: "You Lost!",
                                       message: "Be better next time!",
                                       buttonTitle: "Rematch")
    
    static let draw        = AlertItem(title: "Draw",
                                       message: "You're both unbeatable!",
                                       buttonTitle: "Try Again")
    
    static let difficultyTitle = "Choose Difficulty"
}
