import SwiftUI
import UIKit
import CoreHaptics
import Vortex

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var hapticsEngine: ContinuousHapticsEngine?
    @Environment(\.colorScheme) var colorScheme
    @State private var confettiSystem: VortexSystem?
    
    private func updateConfetti() {
        confettiSystem = VortexSystem.confetti
            .speed(0.4)
            .speedVariation(0.2)
            .position([0.5, 0.04])
            .colors(.random(
                colorScheme == .dark ? .white : .black.opacity(0.8),
                .green.opacity(0.8),
                colorScheme == .dark ? .white : .black.opacity(0.8)
            ))
    }
    
    var body: some View {
        VortexViewReader { proxy in
            ZStack {
                GeometryReader { geometry in
                    VStack {
                        Text("TicTak")
                            .bold()
                            .font(.largeTitle)
                            .foregroundColor(.primary)
                            .italic()
                            .padding(.top, 60)
                        
                        VStack(spacing: 12) {
                            DifficultyMenuView(
                                selectedDifficulty: $viewModel.selectedDifficulty,
                                needsDifficultySelection: $viewModel.needsDifficultySelection,
                                selectDifficultyAction: viewModel.selectDifficulty,
                                isGameboardDisabled: viewModel.isGameInProgress
                            )
                            DifficultyStatusView(
                                selectedDifficulty: $viewModel.selectedDifficulty,
                                needsDifficultySelection: $viewModel.needsDifficultySelection
                            )
                        }
                        .padding(.bottom, 20)
                        Spacer()
                        
                        LazyVGrid(columns: viewModel.columns, spacing: 12) {
                            ForEach(0..<9) { i in
                                ZStack {
                                    GameCircleView(proxy: geometry)
                                    PlayerIndicator(systemImageName: viewModel.moves[i]?.indicator ?? "")
                                        .transition(.scale.combined(with: .opacity))
                                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.moves[i]?.indicator)
                                }
                                .onTapGesture {
                                    viewModel.processPlayerMove(for: i)
                                }
                            }
                        }
                        .disabled(viewModel.needsDifficultySelection)
                        
                        Spacer()
                    }
                }
                .padding()
                
                if let system = confettiSystem {
                    VortexView(system) {
                        Rectangle()
                            .fill(.white)
                            .frame(width: 16, height: 16)
                            .tag("square")
                        Circle()
                            .fill(Color.white)
                            .frame(width: 16, height: 16)
                            .tag("circle")
                    }
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                }
            }
            .onChange(of: viewModel.alertItem) { _, newItem in
                if newItem?.title == AlertContext.humanWin.title {
                    proxy.burst()
                }
            }
        }
                .onAppear {
                    updateConfetti()
                    viewModel.startNewGame()
                    viewModel.showDifficultyDialog = false
                    
                    if hapticsEngine == nil {
                        hapticsEngine = ContinuousHapticsEngine()
                        hapticsEngine?.prepare()
                    }
                }
                .onChange(of: colorScheme) { _, _ in 
                    updateConfetti()
                }
                .alert(item: $viewModel.alertItem) { alertItem in
                    if alertItem.title == AlertContext.computerWin.title {
                        hapticsEngine?.playContinuous(duration: 1.8, intensity: 0.35, sharpness: 0.2)
                    } else if alertItem.title == AlertContext.humanWin.title {
                        Haptics.success()
                    } else if alertItem.title == AlertContext.draw.title {
                        Haptics.warning()
                    }
                    
                    return Alert(
                        title: Text(alertItem.title),
                        message: Text(alertItem.message),
                        dismissButton: .default(Text(alertItem.buttonTitle)) {
                            viewModel.startNewGame()
                        }
                    )
                }
                .disabled(viewModel.isGameboardDisable)
    }
}


#Preview {
    GameView()
}
