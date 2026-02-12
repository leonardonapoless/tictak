import Vortex

extension VortexSystem {
    static func makeConfettiSystem(isDarkMode: Bool) -> VortexSystem {
        VortexSystem.confetti
            .speed(0.4)
            .speedVariation(0.2)
            .position([0.5, 0.04])
            .colors(.random(
                isDarkMode ? .white : .black.opacity(0.8),
                .green.opacity(0.8),
                isDarkMode ? .white : .black.opacity(0.8)
            ))
    }
    
    func speed(_ value: Double) -> VortexSystem {
        let copy = self
        copy.speed = value
        return copy
    }
    
    func speedVariation(_ value: Double) -> VortexSystem {
        let copy = self
        copy.speedVariation = value
        return copy
    }
    
    func position(_ value: SIMD2<Double>) -> VortexSystem {
        let copy = self
        copy.position = value
        return copy
    }
    
    func colors(_ value: ColorMode) -> VortexSystem {
        let copy = self
        copy.colors = value
        return copy
    }
}
