import SwiftUI

struct GlassBackground: View {
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

struct GlassBackgroundTinted: View {
    private let tint = Color.green.opacity(0.18)
    
    var body: some View {
        GlassBackground()
            .overlay(tint)
    }
}

struct GlassCircleStroke: ViewModifier {
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

struct GlassCircle: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Circle()
            .fill(.clear)
            .background(
                ZStack {
                    Color.black.opacity(colorScheme == .dark ? 1.0 : 0.85)
                    GlassBackgroundTinted()
                }
                .clipShape(Circle())
            )
            .modifier(GlassCircleStroke())
    }
}
