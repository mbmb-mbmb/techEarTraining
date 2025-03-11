import Foundation
import AudioKit
import SoundpipeAudioKit

// Class dedicated to EQ processing
class EQProcessor {
    // Audio processing component
    private(set) var equalizer: PeakingParametricEqualizerFilter
    private let inputNode: Node
    
    // Current settings
    var settings: EQSettings {
        didSet {
            updateParameters()
        }
    }
    
    // Initialize with an input node and settings
    init(inputNode: Node, settings: EQSettings = EQSettings()) {
        self.inputNode = inputNode
        self.settings = settings
        self.equalizer = PeakingParametricEqualizerFilter(inputNode)
        updateParameters()
    }
    
    // Update EQ parameters from settings
    private func updateParameters() {
        equalizer.centerFrequency = settings.centerFrequency
        equalizer.q = settings.q
        equalizer.gain = settings.gain
    }
    
    // Helper method to get a random frequency different from current
    private func getRandomFrequency() -> Float {
        // Capture current frequency
        let currentFreq = settings.centerFrequency
        var newFreq: Float
        
        // Make sure we pick a different frequency
        repeat {
            let randomIndex = Int.random(in: 0..<EQSettings.availableFrequencies.count)
            newFreq = EQSettings.availableFrequencies[randomIndex]
        } while newFreq == currentFreq && EQSettings.availableFrequencies.count > 1
        
        return newFreq
    }
    
    // Helper method to get a random gain different from current
    private func getRandomGain() -> Float {
        // Capture current gain
        let currentGain = settings.gain
        var newGain: Float
        
        // Ensure we pick a different gain if possible
        repeat {
            let randomIndex = Int.random(in: 0..<EQSettings.availableGains.count)
            newGain = EQSettings.availableGains[randomIndex]
        } while newGain == currentGain && EQSettings.availableGains.count > 1
        
        return newGain
    }
    
    // Randomize to a different frequency
    func randomizeFrequency() {
        // Create a new settings instance to ensure change detection
        self.settings = EQSettings(frequency: getRandomFrequency(), gain: settings.gain, q: settings.q)
    }
    
    // Randomize both frequency and gain
    func randomize() {
        // Create a new settings instance with both changed values
        self.settings = EQSettings(frequency: getRandomFrequency(), gain: getRandomGain(), q: settings.q)
    }
} 