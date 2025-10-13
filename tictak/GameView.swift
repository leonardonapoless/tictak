import SwiftUI
import UIKit
import CoreHaptics


struct DifficultyMenuView: View {
    @Binding var selectedDifficulty: Difficulty?
    @Binding var needsDifficultySelection: Bool
    var selectDifficultyAction: (Difficulty) -> Void
    var isGameboardDisabled: Bool
    
    var body: some View {
        Picker("Difficulty", selection: $selectedDifficulty) {
            ForEach(Difficulty.allCases) { difficulty in
                Text(difficulty.rawValue).tag(difficulty as Difficulty?)
            }
        }
        .pickerStyle(.segmented)
        .glassEffect()
        .frame(width: 240, height: 50)
        .disabled(isGameboardDisabled)
        .opacity(isGameboardDisabled ? 0.5 : 1.0)
    }
}


struct DifficultyStatusView: View {
    @Binding var selectedDifficulty: Difficulty?
    @Binding var needsDifficultySelection: Bool
    
    var body: some View {
        Group {
            if let difficulty = selectedDifficulty {
                Text(difficulty.rawValue)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
                    .id(difficulty.id)
            }
            
            if needsDifficultySelection {
                Text("Choose a difficulty to start playing")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var hapticsEngine: ContinuousHapticsEngine?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("TicTak")
                    .bold()
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                    .italic()
                    .padding(.bottom, -50)
                
                Spacer()

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
        .onAppear {
            viewModel.startNewGame()
            viewModel.showDifficultyDialog = false
            
            if hapticsEngine == nil {
                hapticsEngine = ContinuousHapticsEngine()
                hapticsEngine?.prepare()
            }
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            // trigger haptics
            if alertItem.title == AlertContext.computerWin.title {
                hapticsEngine?.playContinuous(duration: 1.8, intensity: 0.35, sharpness: 0.2)
            } else if alertItem.title == AlertContext.humanWin.title {
                Haptics.success()
            } else if alertItem.title == AlertContext.draw.title {
                Haptics.warning()
            }
            
            return Alert(
                title: alertItem.title,
                message: alertItem.message,
                dismissButton: .default(alertItem.buttonTitle) {
                    viewModel.startNewGame()
                }
            )
        }
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
        player == .human ? "xmark" : "circle"
    }
}

struct GameCircleView: View {
    var proxy: GeometryProxy
    var body: some View {
        let minSide = max(0, min(proxy.size.width, proxy.size.height))
        let gridSpacing: CGFloat = 12
        let baseSize = (minSide - (gridSpacing * 2)) / 3 - 5
        let cellSize = max(0, baseSize.isFinite ? baseSize : 0)
        
        GlassCircle()
            .frame(width: cellSize, height: cellSize)
    }
}

struct PlayerIndicator: View {
    var systemImageName: String
    @State private var appear = false
    
    var body: some View {
        Image(systemName: systemImageName)
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundStyle(.white.opacity(0.95))
            .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
            .scaleEffect(appear && !systemImageName.isEmpty ? 1.0 : 0.6)
            .opacity(systemImageName.isEmpty ? 0 : 1)
            .onChange(of: systemImageName) { _, newValue in
                if !newValue.isEmpty {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        appear = true
                    }
                    Haptics.playLight()
                }
            }
            .onAppear {
                if !systemImageName.isEmpty {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        appear = true
                    }
                }
            }
    }
}

// MARK: - Liquid Glass Helpers

private struct GlassBackground: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.18),
                            .white.opacity(0.06),
                            .white.opacity(0.02),
                            .black.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.35),
                            .white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.screen)
                )
                .overlay(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.12),
                            .clear,
                            .white.opacity(0.08),
                            .clear
                        ]),
                        center: .center
                    )
                    .blur(radius: 12)
                    .opacity(0.4)
                )
        }
    }
}

private struct GlassBackgroundTinted: View {
    private let tint = Color.green.opacity(0.18)
    var body: some View {
        GlassBackground()
            .overlay(tint)
    }
}

private struct GlassStroke: ViewModifier {
    var cornerRadius: CGFloat
    var lineWidth: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.65), .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: lineWidth
                    )
            }
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.black.opacity(0.18), lineWidth: 0.5)
                    .blur(radius: 1.2)
                    .mask(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.black, .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
            }
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
            .shadow(color: .white.opacity(0.25), radius: 2, x: 0, y: -1)
    }
}

private struct GlassCircleStroke: ViewModifier {
    var lineWidth: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.65),
                                .white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: lineWidth
                    )
            )
            .overlay(
                Circle()
                    .stroke(.black.opacity(0.18), lineWidth: 0.5)
                    .blur(radius: 1.2)
                    .mask(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.black, .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
            .shadow(color: .white.opacity(0.25), radius: 2, x: 0, y: -1)
    }
}

struct GlassRoundedRect: View {
    var cornerRadius: CGFloat = 20
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.clear)
            .background(
                GlassBackground()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .modifier(GlassStroke(cornerRadius: cornerRadius))
    }
}

struct GlassCircle: View {
    var body: some View {
        Circle()
            .fill(.clear)
            .background(
                GlassBackgroundTinted()
                    .clipShape(Circle())
            )
            .modifier(GlassCircleStroke())
    }
}


#Preview {
    GameView()
}
