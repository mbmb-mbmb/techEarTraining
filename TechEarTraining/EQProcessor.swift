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
    
    // Randomize to a different frequency
    func randomizeFrequency() {
        // Capture current frequency
        let currentFreq = settings.centerFrequency
        var newFreq: Float
        
        // Make sure we pick a different frequency
        repeat {
            let randomIndex = Int.random(in: 0..<EQSettings.availableFrequencies.count)
            newFreq = EQSettings.availableFrequencies[randomIndex]
        } while newFreq == currentFreq && EQSettings.availableFrequencies.count > 1
        
        // Create a new settings instance to ensure change detection
        self.settings = EQSettings(frequency: newFreq, gain: settings.gain, q: settings.q)
    }
    
    // Randomize both frequency and gain
    func randomize() {
        // Capture current values
        let currentFreq = settings.centerFrequency
        let currentGain = settings.gain
        
        // New values to assign
        var newFreq: Float
        var newGain: Float
        
        // Ensure we pick a different frequency if possible
        repeat {
            let randomIndex = Int.random(in: 0..<EQSettings.availableFrequencies.count)
            newFreq = EQSettings.availableFrequencies[randomIndex]
        } while newFreq == currentFreq && EQSettings.availableFrequencies.count > 1
        
        // Ensure we pick a different gain if possible
        repeat {
            let randomIndex = Int.random(in: 0..<EQSettings.availableGains.count)
            newGain = EQSettings.availableGains[randomIndex]
        } while newGain == currentGain && EQSettings.availableGains.count > 1
        
        // Create a new settings instance with both changed values
        self.settings = EQSettings(frequency: newFreq, gain: newGain, q: settings.q)
    }
} 