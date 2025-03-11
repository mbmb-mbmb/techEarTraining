import Foundation
import SwiftUI
import AudioKit

// Class to handle the ear training game logic
class GameLogic: ObservableObject {
    // Audio system reference
    private var audioSystem: AudioSystem
    
    // Game state
    @Published var score = 0
    @Published var totalTries = 0
    @Published var isCorrectGuess = false
    @Published var hasGuessed = false
    @Published var activeFrequency: Float = 0
    @Published var activeGain: Float = 0
    
    init(audioSystem: AudioSystem) {
        self.audioSystem = audioSystem
        
        // Initialize with random EQ settings
        randomizeEQSettings()
    }
    
    // Start a new round
    func startNewRound() {
        // Reset guess state
        hasGuessed = false
        isCorrectGuess = false
        tempFrequency = 0
        tempGain = 0
        
        // Randomize to a new EQ setting
        randomizeEQSettings()
        
        // Make sure EQ is on and audio is playing
        if audioSystem.eqBypassed {
            audioSystem.eqBypassed = false
        }
        
        if !audioSystem.isPlaying {
            audioSystem.togglePlayback()
        }
    }
    
    // Reset the game
    func resetGame() {
        score = 0
        totalTries = 0
        startNewRound()
    }
    
    // Randomize EQ settings
    private func randomizeEQSettings() {
        audioSystem.randomizeEQ()
        activeFrequency = audioSystem.eqSettings.centerFrequency
        activeGain = audioSystem.eqSettings.gain
    }
    
    // Check if the user's guess is correct
    func checkGuess(frequency: Float, gain: Float) {
        hasGuessed = true
        totalTries += 1
        
        // Store the user's guess
        tempFrequency = frequency
        tempGain = gain
        
        // Check if the guess matches the current active settings
        if frequency == activeFrequency && gain == activeGain {
            isCorrectGuess = true
            score += 1
            
            // Apply the correct EQ settings
            let settings = audioSystem.eqSettings
            settings.centerFrequency = activeFrequency
            settings.gain = activeGain
            audioSystem.eqSettings = settings
        } else {
            isCorrectGuess = false
            
            // Apply the user's selected EQ settings
            let settings = audioSystem.eqSettings
            settings.centerFrequency = frequency
            settings.gain = gain
            audioSystem.eqSettings = settings
        }
        
        // Start a new round after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.startNewRound()
        }
        
        // Notify UI of changes
        objectWillChange.send()
    }
    
    // Determine the background color for an EQ button
    func backgroundColor(frequency: Float, gain: Float) -> Color {
        if hasGuessed {
            // If this is the correct answer
            if activeFrequency == frequency && activeGain == gain {
                return isCorrectGuess ? Color.green : Color.red.opacity(0.8)
            } else {
                // If this is the user's wrong guess
                if !isCorrectGuess && tempFrequency == frequency && tempGain == gain {
                    return Color.orange
                }
                // Other buttons
                return gain > 0 ? Color.blue.opacity(0.3) : Color.orange.opacity(0.3)
            }
        } else {
            return gain > 0 ? Color.blue : Color.orange
        }
    }
    
    // Temporary storage for user's guess
    private var tempFrequency: Float = 0
    private var tempGain: Float = 0
} 