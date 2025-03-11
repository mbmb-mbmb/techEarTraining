//
//  ContentView.swift
//  FiguringOutNodes
//
//  Created by Markus Bonsdorff on 11.3.2025.
//
import SwiftUI
import AudioKit
import SoundpipeAudioKit
import UniformTypeIdentifiers

struct ContentView: View {
    // Use StateObject to create and manage the audio system and game logic
    @StateObject private var audioSystem = AudioSystem()
    @StateObject private var gameLogic: GameLogic
    
    // File picker state
    @State private var isShowingFilePicker = false
    @State private var isShowingSamplePicker = false
    
    // Initialize with audio system and game logic
    init() {
        // Create audio system first
        let audioSystem = AudioSystem()
        
        // Then create game logic with the audio system
        _audioSystem = StateObject(wrappedValue: audioSystem)
        _gameLogic = StateObject(wrappedValue: GameLogic(audioSystem: audioSystem))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Technical Ear Training Game")
                .font(.largeTitle)
                .padding()
            
            // Score display
            Text("Score: \(gameLogic.score)/\(gameLogic.totalTries)")
                .font(.title)
                .padding()
            
            // Audio source info and picker buttons
            VStack(spacing: 8) {
                Text("Audio Source:")
                    .font(.headline)
                
                Text(audioSystem.currentAudioFileName)
                    .font(.subheadline)
                    .padding(.bottom, 4)
                
                HStack(spacing: 15) {
                    // Sample picker button
                    Button(action: {
                        isShowingSamplePicker = true
                    }) {
                        Text("Audio Sources")
                            .font(.headline)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // Custom file picker button
                    Button(action: {
                        isShowingFilePicker = true
                    }) {
                        Text("Load Audio File")
                            .font(.headline)
                            .padding()
                            .background(Color.cyan)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.bottom)
            
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
                        EQButton(gameLogic: gameLogic, frequency: Float(freq), gain: 6.0)
                        
                        // Cut button
                        EQButton(gameLogic: gameLogic, frequency: Float(freq), gain: -6.0)
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
                        .frame(width: 150)
                        .background(audioSystem.eqBypassed ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Reset button
                Button(action: {
                    gameLogic.resetGame()
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
        // File picker for custom audio files
        .fileImporter(
            isPresented: $isShowingFilePicker,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedURL = try result.get().first else { return }
                
                // Access the file's contents
                if selectedURL.startAccessingSecurityScopedResource() {
                    // Load the selected audio file
                    let success = audioSystem.loadAudioFile(fileURL: selectedURL)
                    
                    // Always release the security-scoped resource when finished
                    selectedURL.stopAccessingSecurityScopedResource()
                    
                    if !success {
                        print("Failed to load audio file")
                    }
                } else {
                    print("Failed to access the file")
                }
            } catch {
                print("File selection error: \(error.localizedDescription)")
            }
        }
        // Sample picker sheet
        .sheet(isPresented: $isShowingSamplePicker) {
            SamplePickerView(audioSystem: audioSystem, isPresented: $isShowingSamplePicker)
        }
    }
}

// Sample picker view
struct SamplePickerView: View {
    @ObservedObject var audioSystem: AudioSystem
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(audioSystem.availableSamples) { sample in
                    Button(action: {
                        audioSystem.currentSample = sample
                        isPresented = false
                    }) {
                        HStack {
                            Text(sample.rawValue)
                                .font(.headline)
                            
                            Spacer()
                            
                            if audioSystem.currentSample == sample {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Audio Source")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}

// UTType extension for audio files
extension UTType {
    static var audio: UTType {
        UTType.audiovisualContent
    }
}

#Preview {
    ContentView()
}
