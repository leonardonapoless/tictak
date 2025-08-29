import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    var title: Text
    var message: Text
    var buttonTitle: Text
}

struct AlertContext {
    static let humanWin    = AlertItem(title: Text("You Win!"),
                                       message: Text("You did a great job!"),
                                       buttonTitle: Text("Play Again"))
    
    static let computerWin = AlertItem(title: Text("You Lost!"),
                                       message: Text("Be better next time!"),
                                       buttonTitle: Text("Rematch"))
    
    static let draw        = AlertItem(title: Text("Draw"),
                                       message: Text("You're both unbeatable!"),
                                       buttonTitle: Text("Try Again"))
    
    static let difficultyTitle = Text("Choose Difficulty")
}
