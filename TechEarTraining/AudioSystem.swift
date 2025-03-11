import Foundation
import AudioKit
import SoundpipeAudioKit
import SwiftUI

// Main audio system class that ties together all components and publishes to the UI
class AudioSystem: ObservableObject {
    // Audio engine and components
    private var engine = AudioEngine()
    private var audioPlayer: AudioPlayer
    private var eqProcessor: EQProcessor
    
    // Published properties for UI binding
    @Published var isPlaying = false
    @Published var volume: Double = 0.5 {
        didSet {
            audioPlayer.amplitude = AUValue(volume)
        }
    }
    
    @Published var eqBypassed: Bool = true {
        didSet {
            updateSignalPath()
        }
    }
    
    // Expose EQ settings for UI
    var eqSettings: EQSettings {
        get { eqProcessor.settings }
        set { eqProcessor.settings = newValue }
    }
    
    // Audio file state
    @Published var currentAudioFileName: String = "White Noise (Default)"
    @Published var currentSample: AudioSample = .whiteNoise {
        didSet {
            if currentSample != oldValue {
                loadSample(currentSample)
            }
        }
    }
    
    // Available samples
    var availableSamples: [AudioSample] {
        return AudioSample.allCases
    }
    
    init() {
        // Create components
        self.audioPlayer = AudioPlayer(amplitude: 0.5)
        self.eqProcessor = EQProcessor(inputNode: audioPlayer.player)
        
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
            engine.output = audioPlayer.player  // Bypass EQ
        } else {
            engine.output = eqProcessor.equalizer      // Use EQ
        }
        
        // Restart if it was playing before
        if wasPlaying {
            startPlayback()
        }
    }
    
    // MARK: - Audio file loading
    
    // Load an audio file from a URL
    func loadAudioFile(fileURL: URL) -> Bool {
        let success = audioPlayer.loadAudioFile(fileURL: fileURL)
        
        if success {
            // Get the file name for display
            currentAudioFileName = fileURL.lastPathComponent
            currentSample = .customFile
            
            // Update connections
            eqProcessor = EQProcessor(inputNode: audioPlayer.player)
            updateSignalPath()
        }
        
        return success
    }
    
    // Load a sample from the cookbook
    func loadSample(_ sample: AudioSample) -> Bool {
        print("AudioSystem: Loading sample \(sample.rawValue)")
        
        // Stop playback temporarily
        let wasPlaying = isPlaying
        if wasPlaying {
            stopPlayback()
        }
        
        // Load the sample
        let success = audioPlayer.loadSample(sample)
        
        if success {
            // Update the display name
            currentAudioFileName = sample.rawValue
            currentSample = sample
            
            // Recreate the EQ processor with the new source
            print("AudioSystem: Reconnecting signal chain")
            eqProcessor = EQProcessor(inputNode: audioPlayer.player)
            updateSignalPath()
            
            // Resume playback if it was playing
            if wasPlaying {
                startPlayback()
            }
        } else {
            print("AudioSystem: Failed to load sample \(sample.rawValue)")
        }
        
        return success
    }
    
    // Show file picker to select audio
    func showAudioFilePicker() {
        // This will be implemented in the UI layer
    }
    
    // MARK: - Playback control
    
    // Start audio playback
    func startPlayback() {
        // Start the audio player
        audioPlayer.start()
        
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
        // Stop the audio player
        audioPlayer.stop()
        
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
            stopPlayback()
            startPlayback()
        }
    }
    
    // Cleanup when instance is deallocated
    deinit {
        stopPlayback()
    }
} 