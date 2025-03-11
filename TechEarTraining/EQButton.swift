import SwiftUI

// Reusable EQ button component
struct EQButton: View {
    // Game logic reference
    @ObservedObject var gameLogic: GameLogic
    
    // Button properties
    var frequency: Float
    var gain: Float
    
    var body: some View {
        let isCorrectAnswer = gameLogic.activeFrequency == frequency && gameLogic.activeGain == gain
        let buttonText = "\(Int(frequency)) Hz \(gain > 0 ? "+" : "")\(Int(gain))dB"
        
        return Button(action: {
            gameLogic.checkGuess(frequency: frequency, gain: gain)
        }) {
            Text(buttonText)
                .font(.system(size: 14, weight: .medium))
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(gameLogic.backgroundColor(frequency: frequency, gain: gain))
                )
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isCorrectAnswer && gameLogic.hasGuessed ? Color.white : Color.clear, lineWidth: 3)
                )
                .scaleEffect(isCorrectAnswer && gameLogic.hasGuessed ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: gameLogic.hasGuessed)
        }
        .disabled(gameLogic.hasGuessed)
    }
} 