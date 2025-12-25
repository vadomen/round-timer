import Foundation
import Combine

enum TimerState {
    case idle
    case work
    case rest
    case paused
}

class TimerModel: ObservableObject {
    // Configuration
    @Published var totalRounds: Int = 12
    @Published var workDuration: TimeInterval = 120 // 2 minutes
    @Published var restDuration: TimeInterval = 60  // 1 minute
    
    // Live State
    @Published var currentRound: Int = 1
    @Published var timeRemaining: TimeInterval = 0
    @Published var state: TimerState = .idle
    @Published var progress: Double = 1.0 // 1.0 full, 0.0 empty
    
    private var timer: AnyCancellable?
    private let soundManager = SoundManager.shared
    
    // Internal trackers
    private var initialTimeForCurrentPhase: TimeInterval = 0
    private var hasPlayed10SecWarning = false
    
    func start() {
        if state == .idle {
            // Fresh Start
            currentRound = 1
            startRound()
        } else if state == .paused {
            resume()
        }
    }
    
    func pause() {
        guard state == .work || state == .rest else { return }
        state = .paused
        timer?.cancel()
    }
    
    func resume() {
        guard state == .paused else { return }
        // Determine whether to go back to work or rest based on internal tracking?
        // Actually, we need to know what phase we were in.
        // Simplified: We don't change the phase variable during pause, so we just restart the timer check.
        
        // However, `state` acts as the phase indicator too.
        // We might need a separate variable for `previousState` if we want to distinguish cleanly,
        // but let's assume if we are pausing, we just carry on ticking.
        // Wait: `state` is .paused, so we lost whether it was work or rest.
        // Let's add a helper to track pre-pause state or just use a separate variable for "Phase".
    }

    // Refactored State Machine
    // We'll use a `phase` enum for Logic and `state` for Flow Control.
    enum Phase {
        case work
        case rest
    }
    private var currentPhase: Phase = .work
    
    func reset() {
        stopTimer()
        state = .idle
        currentRound = 1
        timeRemaining = workDuration
        progress = 1.0
        hasPlayed10SecWarning = false
    }
    
    private func startRound() {
        currentPhase = .work
        state = .work
        timeRemaining = workDuration
        initialTimeForCurrentPhase = workDuration
        hasPlayed10SecWarning = false
        soundManager.playRoundStart()
        startTimerTick()
    }
    
    private func startRest() {
        currentPhase = .rest
        state = .rest
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
        guard state == .work || state == .rest else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
            progress = timeRemaining / initialTimeForCurrentPhase
            
            // Checks for warnings
            if timeRemaining == 10 {
                if !hasPlayed10SecWarning {
                    soundManager.playWarning()
                    hasPlayed10SecWarning = true
                }
            }
        } else {
            // Phase Complete
            nextPhase()
        }
    }
    
    private func nextPhase() {
        if currentPhase == .work {
            if currentRound < totalRounds {
                startRest()
            } else {
                // Workout Complete
                finishWorkout()
            }
        } else {
            // Rest Finished, Start Next Round
            currentRound += 1
            startRound()
        }
    }
    
    private func finishWorkout() {
        stopTimer()
        state = .idle
        soundManager.playRoundEnd() // Or a special finish sound
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    // Resume Logic Fix
    // We need to store the phase before pausing so we can restore the correct state.
    // Actually, `state` in the enum mixed Phase (Work/Rest) and Control (Idle/Paused).
    // Let's separate "isRunning" from "Phase".
}

// Improved TimerModel to separate concerns cleanly
class RoundTimerModel: ObservableObject {
    @Published var totalRounds: Int = 12
    @Published var workDuration: TimeInterval = 120
    @Published var restDuration: TimeInterval = 60
    
    @Published var currentRound: Int = 1
    @Published var timeRemaining: TimeInterval = 0
    @Published var progress: Double = 1.0
    
    enum TimerPhase {
        case idle // Not started
        case prepare // 10s warmup
        case work // Boxing
        case rest // Resting
    }
    
    @Published var phase: TimerPhase = .idle
    @Published var isPaused: Bool = false
    
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
