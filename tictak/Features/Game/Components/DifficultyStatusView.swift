import SwiftUI

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
