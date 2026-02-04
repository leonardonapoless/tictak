import SwiftUI

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
