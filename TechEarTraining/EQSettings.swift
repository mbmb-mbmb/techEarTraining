import Foundation
import AudioKit

class EQSettings {
    // Available frequencies to choose from
    static let availableFrequencies: [Float] = [250, 500, 1000, 2000, 4000, 10000]
    
    // Available gain values (in dB) - including cuts (negative values)
    static let availableGains: [Float] = [-6, 6]
    
    // Standard settings
    var centerFrequency: Float = 1000 // Default to 1kHz
    var gain: Float = 6.0  // +6dB boost
    var q: Float = 1.0     // Q value of 1.0
    
    init(frequency: Float = 1000, gain: Float = 6.0, q: Float = 1.0) {
        self.centerFrequency = frequency
        self.gain = gain
        self.q = q
    }
    
    // Randomize just the frequency from available options
    func randomizeFrequency() {
        let randomIndex = Int.random(in: 0..<EQSettings.availableFrequencies.count)
        centerFrequency = EQSettings.availableFrequencies[randomIndex]
    }
    
    // Randomize just the gain from available options
    func randomizeGain() {
        let randomIndex = Int.random(in: 0..<EQSettings.availableGains.count)
        gain = EQSettings.availableGains[randomIndex]
    }
    
    // Randomize both frequency and gain
    func randomize() {
        randomizeFrequency()
        randomizeGain()
    }
    
    // Factory method to create a settings object with random frequency and gain
    static func random() -> EQSettings {
        let settings = EQSettings()
        settings.randomize()
        return settings
    }
} 
