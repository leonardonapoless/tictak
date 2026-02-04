import Vortex

extension VortexSystem {
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
