import Foundation
import Combine

enum TimerPhase {
    case idle // Not started
    case prepare // 10s warmup
    case work // Boxing
    case rest // Resting
}

// Improved TimerModel to separate concerns cleanly
class RoundTimerModel: ObservableObject {
    @Published var totalRounds: Int = 12
    @Published var workDuration: TimeInterval = 120
    @Published var restDuration: TimeInterval = 60
    
    @Published var currentRound: Int = 1
    @Published var timeRemaining: TimeInterval = 0
    @Published var progress: Double = 1.0
    
    @Published var phase: TimerPhase = .idle
    @Published var isPaused: Bool = false
    
    @Published var heartRateManager = HeartRateManager()
    
    private var timer: AnyCancellable?
    private let soundManager = SoundManager.shared
    private var initialTimeForCurrentPhase: TimeInterval = 0
    private var hasPlayed10SecWarning = false
    
    func start() {
        if phase == .idle {
            currentRound = 1
            startPrepare()
        } else if isPaused {
            resume()
        }
    }
    
    func pause() {
        if phase != .idle && !isPaused {
            isPaused = true
            timer?.cancel()
        }
    }
    
    func resume() {
        if isPaused {
            isPaused = false
            startTimerTick()
        }
    }
    
    func stop() {
        timer?.cancel()
        phase = .idle
        isPaused = false
        currentRound = 1
        timeRemaining = workDuration
        progress = 1.0
    }
    
    private func startPrepare() {
        phase = .prepare
        isPaused = false
        timeRemaining = 10
        initialTimeForCurrentPhase = 10
        hasPlayed10SecWarning = false // Reset for cleanliness, though warning logic might differ
        // No sound on prepare start as per user request
        startTimerTick()
    }
    
    private func startRound() {
        phase = .work
        isPaused = false
        timeRemaining = workDuration
        initialTimeForCurrentPhase = workDuration
        hasPlayed10SecWarning = false
        soundManager.playRoundStart()
        startTimerTick()
    }
    
    private func startRest() {
        phase = .rest
        isPaused = false
        timeRemaining = restDuration
        initialTimeForCurrentPhase = restDuration
        hasPlayed10SecWarning = false
        soundManager.playRoundEnd()
        startTimerTick()
    }
    
    private func startTimerTick() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard !isPaused && phase != .idle else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
            progress = timeRemaining / initialTimeForCurrentPhase
            
            if timeRemaining == 3 && phase == .prepare {
                 // 3-2-1 countdown for prepare?
                 soundManager.playWarning()
            }
            
            if timeRemaining == 10 && phase != .prepare {
                soundManager.playWarning()
            }
        } else {
            nextPhase()
        }
    }
    
    private func nextPhase() {
        if phase == .prepare {
            startRound()
        } else if phase == .work {
            if currentRound < totalRounds {
                startRest()
            } else {
                stop()
                soundManager.playRoundEnd()
            }
        } else if phase == .rest {
            currentRound += 1
            startRound()
        }
    }
}
