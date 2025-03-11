// AudioPlayer.swift
// Provides audio file playback or white noise generation for the ear training app
//

import Foundation
import AudioKit
import SoundpipeAudioKit
import AVFoundation

// Sample type enum for built-in samples
enum AudioSample: String, CaseIterable, Identifiable {
    case whiteNoise = "White Noise"
    case pinkNoise = "Pink Noise"
    case brownianNoise = "Brownian Noise"
    case customFile = "Custom Audio File"
    
    var id: String { self.rawValue }
    
    // Is this a generated noise type?
    var isGeneratedNoise: Bool {
        return self != .customFile
    }
}

// AudioPlayer class that replaces the noise generator
class AudioPlayer {
    // Audio engine components
    private var audioFile: AVAudioFile?
    private var whiteNoise: WhiteNoise?
    private var pinkNoise: PinkNoise?
    private var brownianNoise: BrownianNoise?
    private var audioFilePlayer: AudioKit.AudioPlayer?
    
    // The node output that can be connected to other nodes
    private(set) var player: Node
    
    // Basic properties
    var amplitude: AUValue = 0.5 {
        didSet {
            updateVolume()
        }
    }
    
    // URL of the currently loaded file
    private(set) var audioFileURL: URL?
    
    // Currently selected sample
    private(set) var currentSample: AudioSample = .whiteNoise
    
    init(amplitude: AUValue = 0.5) {
        // Create a temporary white noise as default
        let noise = WhiteNoise()
        noise.amplitude = amplitude
        self.whiteNoise = noise
        self.player = noise
        self.amplitude = amplitude
    }
    
    // Load an audio file from a URL
    func loadAudioFile(fileURL: URL) -> Bool {
        do {
            // Create an AVAudioFile instance
            let audioFile = try AVAudioFile(forReading: fileURL)
            self.audioFile = audioFile
            
            // Create a proper AudioKit player
            if let newPlayer = try? AudioKit.AudioPlayer(file: audioFile) {
                newPlayer.isLooping = true
                newPlayer.volume = self.amplitude
                
                // Store player and update references
                self.audioFilePlayer = newPlayer
                self.player = newPlayer
                self.audioFileURL = fileURL
                self.currentSample = .customFile
                
                return true
            } else {
                print("Failed to create audio player")
                return false
            }
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
            return false
        }
    }
    
    // Load a sample from the AudioKit cookbook
    func loadSample(_ sample: AudioSample) -> Bool {
        print("Attempting to load sample: \(sample.rawValue)")
        
        // If this is a generated noise type
        if sample.isGeneratedNoise {
            print("Loading generated noise: \(sample.rawValue)")
            
            // Clean up any existing audio player
            if audioFilePlayer != nil {
                audioFilePlayer = nil
            }
            
            // Reset all noise generators
            whiteNoise = nil
            pinkNoise = nil
            brownianNoise = nil
            
            // Create the appropriate noise generator
            switch sample {
            case .whiteNoise:
                let noise = WhiteNoise()
                noise.amplitude = amplitude
                self.whiteNoise = noise
                self.player = noise
                
            case .pinkNoise:
                let noise = PinkNoise()
                noise.amplitude = amplitude
                self.pinkNoise = noise
                self.player = noise
                
            case .brownianNoise:
                let noise = BrownianNoise()
                noise.amplitude = amplitude
                self.brownianNoise = noise
                self.player = noise
                
            default:
                break
            }
            
            self.currentSample = sample
            return true
        } else if sample == .customFile && audioFileURL != nil {
            // If custom file is selected but we already have a file loaded
            return true
        } else {
            // If custom file is selected but no file is loaded
            print("No custom file loaded. Please use the 'Load Audio File' button.")
            return false
        }
    }
    
    // Load a default audio file from the bundle
    func loadDefaultAudio() -> Bool {
        // Default to white noise
        return loadSample(.whiteNoise)
    }
    
    // Update the volume based on amplitude
    private func updateVolume() {
        if let player = audioFilePlayer {
            player.volume = amplitude
        } else if let noise = whiteNoise {
            noise.amplitude = amplitude
        } else if let noise = pinkNoise {
            noise.amplitude = amplitude
        } else if let noise = brownianNoise {
            noise.amplitude = amplitude
        }
    }
    
    // Control methods
    func start() {
        if let player = audioFilePlayer {
            do {
                try player.play()
            } catch {
                print("Error playing audio file: \(error.localizedDescription)")
            }
        } else if let noise = whiteNoise {
            noise.start()
        } else if let noise = pinkNoise {
            noise.start()
        } else if let noise = brownianNoise {
            noise.start()
        }
    }
    
    func stop() {
        if let player = audioFilePlayer {
            player.stop()
        } else if let noise = whiteNoise {
            noise.stop()
        } else if let noise = pinkNoise {
            noise.stop()
        } else if let noise = brownianNoise {
            noise.stop()
        }
    }
} 
