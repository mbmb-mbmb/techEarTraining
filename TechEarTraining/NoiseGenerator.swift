import Foundation
import AudioKit
import SoundpipeAudioKit

// Simple class focused only on generating white noise
class NoiseGenerator {
    // Sound generation component
    private(set) var whiteNoise = WhiteNoise()
    
    // Basic properties
    var amplitude: AUValue {
        get { whiteNoise.amplitude }
        set { whiteNoise.amplitude = newValue }
    }
    
    init(amplitude: AUValue = 0.5) {
        self.whiteNoise.amplitude = amplitude
    }
    
    // Control methods
    func start() {
        whiteNoise.start()
    }
    
    func stop() {
        whiteNoise.stop()
    }
} 