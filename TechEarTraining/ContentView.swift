//
//  ContentView.swift
//  FiguringOutNodes
//
//  Created by Markus Bonsdorff on 11.3.2025.
//
import SwiftUI
import AudioKit
import SoundpipeAudioKit

struct ContentView: View {
    // Use StateObject to create and manage the audio system
    @StateObject private var audioSystem = AudioSystem()
    
    // Game state
    @State private var score = 0
    @State private var isCorrectGuess = false
    @State private var hasGuessed = false
    @State private var activeFrequency: Float = 0
    @State private var activeGain: Float = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Technical Ear Training Game")
                .font(.largeTitle)
                .padding()
            
            // Score display
            Text("Score: \(score)")
                .font(.title)
                .padding()
            
            // Volume control
            VStack {
                Text("Volume: \(Int(audioSystem.volume * 100))%")
                    .font(.headline)
                
                Slider(value: $audioSystem.volume, in: 0...1)
                    .padding(.horizontal)
            }
            .padding(.bottom)
            
            // EQ button grid - 2x6 layout
            VStack(spacing: 10) {
                // Header Row
                HStack {
                    Text("Boost (+6dB)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    
                    Text("Cut (-6dB)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                
                // Frequency rows
                ForEach([250, 500, 1000, 2000, 4000, 10000], id: \.self) { freq in
                    HStack(spacing: 10) {
                        // Boost button
                        eqButton(frequency: Float(freq), gain: 6.0)
                        
                        // Cut button
                        eqButton(frequency: Float(freq), gain: -6.0)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Control buttons
            HStack(spacing: 20) {
                // EQ bypass button
                Button(action: {
                    audioSystem.eqBypassed.toggle()
                }) {
                    Text(audioSystem.eqBypassed ? "EQ: Off" : "EQ: On")
                        .font(.headline)
                        .padding()
                        .frame(width: 120)
                        .background(audioSystem.eqBypassed ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Start/Next Round button
                Button(action: {
                    score = 0 // Reset score counter
                    startNewRound()
                }) {
                    Text("Reset")
                        .font(.headline)
                        .padding()
                        .frame(width: 150)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            // Play/Stop button
            Button(action: {
                audioSystem.togglePlayback()
            }) {
                Text(audioSystem.isPlaying ? "Stop" : "Play")
                    .font(.title2)
                    .padding()
                    .frame(width: 200)
                    .background(audioSystem.isPlaying ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            // Initialize with a random EQ setting but don't start playback yet
            audioSystem.randomizeEQ()
            activeFrequency = audioSystem.eqSettings.centerFrequency
            activeGain = audioSystem.eqSettings.gain
        }
    }
    
    // Game functions
    private func startNewRound() {
        // Reset guess state
        hasGuessed = false
        isCorrectGuess = false
        
        // Randomize to a new EQ setting
        audioSystem.randomizeEQ()
        
        // Store the active settings for comparison
        activeFrequency = audioSystem.eqSettings.centerFrequency
        activeGain = audioSystem.eqSettings.gain
        
        // Make sure EQ is on and noise is playing
        if audioSystem.eqBypassed {
            audioSystem.eqBypassed = false
        }
        
        if !audioSystem.isPlaying {
            audioSystem.togglePlayback()
        }
    }
    
    private func checkGuess(frequency: Float, gain: Float) {
        hasGuessed = true
        
        // Check if the guess matches the current active settings
        if frequency == activeFrequency && gain == activeGain {
            isCorrectGuess = true
            score += 1
            
            // Delay before starting the next round
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                startNewRound()
            }
        } else {
            isCorrectGuess = false
            
            // Update the EQ to show what the user selected (for comparison)
            let tempSettings = audioSystem.eqSettings
            tempSettings.centerFrequency = frequency
            tempSettings.gain = gain
            audioSystem.eqSettings = tempSettings
            
            // Delay before showing the correct answer
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Restore the original settings to show the correct answer
                let originalSettings = audioSystem.eqSettings
                originalSettings.centerFrequency = activeFrequency
                originalSettings.gain = activeGain
                audioSystem.eqSettings = originalSettings
                
                // Delay before starting a new round
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    startNewRound()
                }
            }
        }
    }
    
    private func eqButton(frequency: Float, gain: Float) -> some View {
        let isActive = activeFrequency == frequency && activeGain == gain
        let buttonText = "\(Int(frequency)) Hz \(gain > 0 ? "+" : "")\(Int(gain))dB"
        
        return Button(action: {
            checkGuess(frequency: frequency, gain: gain)
        }) {
            Text(buttonText)
                .font(.system(size: 14, weight: .medium))
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor(frequency: frequency, gain: gain))
                )
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isActive && hasGuessed && isCorrectGuess ? Color.white : Color.clear, lineWidth: 3)
                )
        }
        .disabled(hasGuessed)
    }
    
    private func backgroundColor(frequency: Float, gain: Float) -> Color {
        if hasGuessed {
            if activeFrequency == frequency && activeGain == gain {
                return isCorrectGuess ? Color.green : Color.red
            } else {
                return gain > 0 ? Color.blue.opacity(0.5) : Color.orange.opacity(0.5)
            }
        } else {
            return gain > 0 ? Color.blue : Color.orange
        }
    }
}

#Preview {
    ContentView()
}
