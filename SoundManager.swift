import Foundation
import AudioToolbox
import AVFoundation

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    // System Sound IDs
    // 1005 - Alarm
    // 1111 - Beep
    // 1016 - Tweet/Whistle-ish
    // 1025 - Fanfare (maybe too long)
    
    // Using standard system sounds for simplicity.
    // In a real app, you'd bundle .mp3/.wav files and use AVAudioPlayer.
    
    func playRoundStart() {
        // A distinctive gong or bell sound
        playSound(systemSoundID: 1005) // Simulating a bell with a system alarm sound for now
    }
    
    func playRoundEnd() {
        // A double bell or distinct end sound
        playSound(systemSoundID: 1005)
    }
    
    func playWarning() {
        // A short beep or woodblock
        playSound(systemSoundID: 1111) // System generic beep
    }
    
    private func playSound(systemSoundID: SystemSoundID) {
        AudioServicesPlaySystemSound(systemSoundID)
    }
}
