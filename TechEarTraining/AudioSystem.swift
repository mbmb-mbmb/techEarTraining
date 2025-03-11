import Foundation
import AudioKit
import SoundpipeAudioKit
import SwiftUI

// Main audio system class that ties together all components and publishes to the UI
class AudioSystem: ObservableObject {
    // Audio engine and components
    private var engine = AudioEngine()
    private var noiseGenerator: NoiseGenerator
    private var eqProcessor: EQProcessor
    
    // Published properties for UI binding
    @Published var isPlaying = false
    @Published var volume: Double = 0.5 {
        didSet {
            noiseGenerator.amplitude = AUValue(volume)
        }
    }
    
    @Published var eqBypassed: Bool = false {
        didSet {
            updateSignalPath()
        }
    }
    
    // Expose EQ settings for UI
    var eqSettings: EQSettings {
        get { eqProcessor.settings }
        set { eqProcessor.settings = newValue }
    }
    
    init() {
        // Create components
        self.noiseGenerator = NoiseGenerator(amplitude: 0.5)
        self.eqProcessor = EQProcessor(inputNode: noiseGenerator.whiteNoise)
        
        // Setup initial connections
        updateSignalPath()
    }
    
    // MARK: - Signal path management
    
    // Update the signal path based on bypass state
    private func updateSignalPath() {
        // Stop engine if it's running to change connections
        let wasPlaying = isPlaying
        if wasPlaying {
            stopPlayback()
        }
        
        // Set the output based on bypass state
        if eqBypassed {
            engine.output = noiseGenerator.whiteNoise  // Bypass EQ
        } else {
            engine.output = eqProcessor.equalizer      // Use EQ
        }
        
        // Restart if it was playing before
        if wasPlaying {
            startPlayback()
        }
    }
    
    // MARK: - Playback control
    
    // Start audio playback
    func startPlayback() {
        // Start the noise generator
        noiseGenerator.start()
        
        // Start the audio engine
        do {
            try engine.start()
            isPlaying = true
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }
    
    // Stop audio playback
    func stopPlayback() {
        // Stop the noise generator
        noiseGenerator.stop()
        
        // Stop the audio engine
        engine.stop()
        isPlaying = false
    }
    
    // Toggle playback state
    func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    // MARK: - EQ control
    
    // Randomize EQ frequency and gain
    func randomizeEQ() {
        // Use the randomize method that changes both frequency and gain
        eqProcessor.randomize()
        
        // Force a UI update (sometimes needed for SwiftUI)
        objectWillChange.send()
        
        // If playing with EQ, briefly restart to ensure changes take effect
        if isPlaying && !eqBypassed {
            let wasPlaying = isPlaying
            if wasPlaying {
                stopPlayback()
                startPlayback()
            }
        }
    }
    
    // Cleanup when instance is deallocated
    deinit {
        stopPlayback()
    }
} 