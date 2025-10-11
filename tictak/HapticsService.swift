import Foundation
import UIKit
import CoreHaptics

// MARK: - Tap haptics

enum Haptics {
    static func playLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    static func playMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

// MARK: - Long haptics

struct ContinuousHapticsEngine {
    private var engine: CHHapticEngine?
    private var supportsHaptics: Bool = false
    
    init() {
        prepare()
    }
    
    mutating func prepare() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        guard supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            supportsHaptics = false
            engine = nil
        }
    }
    
    func playContinuous(duration: TimeInterval, intensity: Float = 1.0, sharpness: Float = 0.5) {
        guard supportsHaptics, let engine else { return }
        let clampedDuration = max(0.1, min(2.0, duration))
        
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let event = CHHapticEvent(eventType: .hapticContinuous,
                                  parameters: [intensityParam, sharpnessParam],
                                  relativeTime: 0,
                                  duration: clampedDuration)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            // fail silently on unsupported devices or engine errors
        }
    }
}
