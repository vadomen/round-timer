import Foundation
import AudioToolbox
import AVFoundation
import Combine

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    // Audio Players
    private var boxingBellPlayer: AVAudioPlayer?
    private var warningSoundPlayer: AVAudioPlayer?
    
    // System Sound IDs (Fallbacks)
    private var defaultAlarmID: SystemSoundID = 1005
    private var defaultBeepID: SystemSoundID = 1111
    
    private init() {
        configureAudioSession()
        loadSounds()
    }
    
    private func configureAudioSession() {
        do {
            // .playback ensures audio continues even if the silent switch is on,
            // and plays at the standard media volume level.
            // .duckOthers lowers background music (like Spotify) while the bell rings.
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure AudioSession: \(error)")
        }
    }
    
    private func loadSounds() {
        boxingBellPlayer = createPlayer(filename: "boxing-bell", ext: "mp3")
        warningSoundPlayer = createPlayer(filename: "gavel-3", ext: "mp3")
    }
    
    private func createPlayer(filename: String, ext: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else { return nil }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            print("Failed to load sound \(filename).\(ext): \(error)")
            return nil
        }
    }
    
    func playRoundStart() {
        play(player: boxingBellPlayer, fallback: defaultAlarmID)
    }
    
    func playRoundEnd() {
        play(player: boxingBellPlayer, fallback: defaultAlarmID)
    }
    
    func playWarning() {
        play(player: warningSoundPlayer, fallback: defaultBeepID)
    }
    
    private func play(player: AVAudioPlayer?, fallback: SystemSoundID) {
        if let player = player {
            if player.isPlaying {
                player.stop()
                player.currentTime = 0
            }
            player.play()
        } else {
            // Fallback to system sound if file is missing
            AudioServicesPlaySystemSound(fallback)
        }
    }
}
