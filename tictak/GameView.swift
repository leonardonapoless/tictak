//
//  GameView.swift
//  tictak
//
//  Created by Leonardo Nápoles on 8/5/25.
//

import SwiftUI

struct GameView: View {
    
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
//                Spacer()

                Text("TicTak")
                    .bold()
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                    .italic()
                    .padding(.bottom, -50)
                
                
                Spacer()

                // TODO: Implement difficulty view model
                
                let difficulties = ["Easy", "Medium", "Hard"]
                VStack {
                    Text("Difficulty")
                        .bold()
                        .padding()
                    HStack {
                        ForEach(difficulties, id: \.self) { difficultyText in
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 50)
                                Text(difficultyText)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .onTapGesture {
                                print("\(difficultyText) tapped")
                            }
                        }
                    }
                    
                }
                Spacer()
                
                LazyVGrid(columns: viewModel.columns, spacing: 5) {
                    ForEach(0..<9) { i in
                        ZStack {
                            GameCircleView(proxy: geometry)
                            PlayerIndicator(systemImageName: viewModel.moves[i]?.indicator ?? "")
                        }
                        .onTapGesture {
                            viewModel.processPlayerMove(for: i)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding()
        .alert(item: $viewModel.alertItem, content: { alertItem in
            Alert(title: alertItem.title,
                  message: alertItem.message,
                  dismissButton: .default(alertItem.buttonTitle, action: { viewModel.resetGame() }))
        })
        .disabled(viewModel.isGameboardDisable)
    }
}

enum Player {
    case human, computer
}

struct Move {
    let player: Player
    let boardIndex: Int
    
    var indicator: String {
        return player == .human ? "xmark" : "circle"
    }
}


#Preview {
    GameView()
}

struct GameCircleView: View {
    
    var proxy: GeometryProxy
    var body: some View {
        Circle()
            .foregroundStyle(.teal).opacity(0.5)
            .frame(width: proxy.size.width/3 - 15,
                   height: proxy.size.width/3 - 15)
    }
}

struct PlayerIndicator: View {
    
//    Image(systemName: viewModel.moves[i]?.indicator ?? "")

    var systemImageName: String
    var body: some View {
        Image(systemName: systemImageName)
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundStyle(.white)
    }
}
