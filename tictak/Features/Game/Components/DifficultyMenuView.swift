import SwiftUI

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
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}
