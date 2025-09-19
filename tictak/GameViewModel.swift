import SwiftUI

enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var id: String { rawValue }
}

final class GameViewModel: ObservableObject {
    // Audio dependency
    private let audioService: AudioService

    init(audioService: AudioService = AudioService()) {
        self.audioService = audioService
    }

    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    let rows: [GridItem] = [GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())]
    
    @Published var moves: [Move?] = Array(repeating: nil, count: 9)
    @Published var isGameboardDisable = false
    @Published var alertItem: AlertItem?
    
    // Difficulty state
    @Published var selectedDifficulty: Difficulty? = nil
    @Published var needsDifficultySelection: Bool = true
    @Published var showDifficultyDialog: Bool = false

    func startNewGame() {
        selectedDifficulty = nil
        needsDifficultySelection = true
        resetGame()
        showDifficultyDialog = false
    }
    
    func selectDifficulty(_ difficulty: Difficulty) {
        selectedDifficulty = difficulty
        needsDifficultySelection = false
        showDifficultyDialog = false
    }
    
    func processPlayerMove(for position: Int) {
        guard selectedDifficulty != nil, !needsDifficultySelection else { return }
        if isSquareOccupied(in: moves, forIndex: position) { return }
        
        moves[position] = Move(player: .human, boardIndex: position)
        audioService.playSound(named: SoundEffect.playerMove.fileName)
        
        if checkWinCondition(for: .human, in: moves) {
            audioService.playSound(named: SoundEffect.playerWin.fileName)
            alertItem = AlertContext.humanWin
            return
        }
    
        if checkForDraw(in: moves) {
            alertItem = AlertContext.draw
            audioService.playSound(named: SoundEffect.draw.fileName)
            return
        }
        
        isGameboardDisable = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            let computerPosition = determineComputerMovePosition(in: moves)
            moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
            audioService.playSound(named: SoundEffect.computerMove.fileName)
            isGameboardDisable = false
            
            if checkWinCondition(for: .computer, in: moves) {
                alertItem = AlertContext.computerWin
                audioService.playSound(named: SoundEffect.playerLose.fileName)
            }
            
            if checkForDraw(in: moves) {
                alertItem = AlertContext.draw
                audioService.playSound(named: SoundEffect.draw.fileName)
                return
            }
        }
    }
        
    // MARK: - Game Logic
    
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        moves.contains(where: { $0?.boardIndex == index })
    }
    
    func availableMoves(in moves: [Move?]) -> [Int] {
        (0..<9).filter { !isSquareOccupied(in: moves, forIndex: $0) }
    }
    
    func determineComputerMovePosition(in moves: [Move?]) -> Int {
        guard let difficulty = selectedDifficulty else {
            return determineMediumMove(in: moves)
        }
        switch difficulty {
        case .easy:
            return determineEasyMove(in: moves)
        case .medium:
            return determineMediumMove(in: moves)
        case .hard:
            return determineHardMove(in: moves)
        }
    }
    
    // MARK: - Difficulty Behaviors
    
    private func determineEasyMove(in moves: [Move?]) -> Int {
        let avail = availableMoves(in: moves)
        guard !avail.isEmpty else { return 0 }
        
        if Int.random(in: 0..<100) < 20 {
            if let win = immediateWinIndex(for: .computer, in: moves) { return win }
            if let block = immediateWinIndex(for: .human, in: moves) { return block }
        }
        return avail.randomElement()!
    }
    
    private func determineMediumMove(in moves: [Move?]) -> Int {
        if let win = immediateWinIndex(for: .computer, in: moves) { return win }
        if let block = immediateWinIndex(for: .human, in: moves) { return block }
        
        let center = 4
        if !isSquareOccupied(in: moves, forIndex: center) { return center }
        
        var movePosition = Int.random(in: 0..<9)
        while isSquareOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        return movePosition
    }
    
    private func determineHardMove(in moves: [Move?]) -> Int {
        if let win = immediateWinIndex(for: .computer, in: moves) { return win }
        if let block = immediateWinIndex(for: .human, in: moves) { return block }
        
        let center = 4
        if !isSquareOccupied(in: moves, forIndex: center) { return center }
        
        let corners = [0, 2, 6, 8].filter { !isSquareOccupied(in: moves, forIndex: $0) }
        if let corner = corners.randomElement() { return corner }
        
        let sides = [1, 3, 5, 7].filter { !isSquareOccupied(in: moves, forIndex: $0) }
        if let side = sides.randomElement() { return side }
        
        return availableMoves(in: moves).first ?? 0
    }
    
    // MARK: - Helpers
    
    private func immediateWinIndex(for player: Player, in moves: [Move?]) -> Int? {
        let winPatterns: Set<Set<Int>> = [
            [0,1,2], [3,4,5], [6,7,8],
            [0,3,6], [1,4,7], [2,5,8],
            [0,4,8], [2,4,6]
        ]
        
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player }
        let positions = Set(playerMoves.map { $0.boardIndex })
        
        for pattern in winPatterns {
            let remaining = pattern.subtracting(positions)
            if remaining.count == 1 {
                let idx = remaining.first!
                if !isSquareOccupied(in: moves, forIndex: idx) {
                    return idx
                }
            }
        }
        return nil
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        let winPatterns: Set<Set<Int>> = [[0,1,2], [3,4,5], [6,7,8],
                                          [0,3,6], [1,4,7], [2,5,8],
                                          [0,4,8], [2,4,6]]
        
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player}
        let playerPositions = Set(playerMoves.map { $0.boardIndex })
        
        for pattern in winPatterns where pattern.isSubset(of: playerPositions) { return true }
        return false
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        moves.compactMap { $0 }.count == 9
    }
    
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
        isGameboardDisable = false
        alertItem = nil
    }
}
