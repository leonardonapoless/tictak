import SwiftUI

struct PlayerIndicator: View {
    var systemImageName: String
    @Environment(\.colorScheme) var colorScheme
    @State private var appear = false
    
    var body: some View {
        Image(systemName: systemImageName)
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.95) : .black)
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
