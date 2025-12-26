import SwiftUI

struct TimerView: View {
    @ObservedObject var timerModel: RoundTimerModel
    @Binding var isShowingTimer: Bool
    
    var backgroundColor: Color {
        switch timerModel.phase {
        case .work:
            return timerModel.timeRemaining <= 10 ? Color.orange : Color.green
        case .rest:
            return timerModel.timeRemaining <= 10 ? Color.yellow : Color.red
        case .prepare:
            return Color.blue
        case .idle:
            return Color.gray
        }
    }
    
    var statusText: String {
        switch timerModel.phase {
        case .work: return "ROUND \(timerModel.currentRound)"
        case .rest: return "REST"
        case .prepare: return "GET READY"
        case .idle: return "READY"
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            ZStack {
                backgroundColor
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut, value: backgroundColor)
                
                if isLandscape {
                    // LANDSCAPE LAYOUT
                    ZStack {
                        // Maximize Timer Text
                        Text(formatTime(timerModel.timeRemaining))
                            .font(.system(size: geometry.size.height * 0.85, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .padding()
                            .accessibilityIdentifier("TimerText")
                            .onTapGesture {
                                if timerModel.isPaused {
                                    timerModel.resume()
                                } else {
                                    timerModel.pause()
                                }
                            }
                        
                        // Controls Overlay
                        VStack {
                            HStack {
                                // Stop Button (Top Left)
                                Button(action: {
                                    timerModel.stop()
                                    withAnimation {
                                        isShowingTimer = false
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding()
                                }
                                .accessibilityIdentifier("StopButton")
                                
                                Spacer()
                                
                                // Round Number (Top Center)
                                Text("ROUND \(timerModel.currentRound)")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.top)
                                
                                Spacer()
                                
                                // Pause Button (Top Right)
                                Button(action: {
                                    if timerModel.isPaused {
                                        timerModel.resume()
                                    } else {
                                        timerModel.pause()
                                    }
                                }) {
                                    Image(systemName: timerModel.isPaused ? "play.circle.fill" : "pause.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding()
                                }
                                .accessibilityIdentifier("PauseButton")
                            }
                            Spacer()
                        }
                        
                        // Paused Indicator Overlay
                        if timerModel.isPaused {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.white.opacity(0.5))
                                .allowsHitTesting(false) // Let tap gesture handle it
                        }
                    }
                } else {
                    // PORTRAIT LAYOUT
                    VStack(spacing: 40) {
                        // Header
                        Text(statusText)
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 50)
                        
                        Spacer()
                        
                        // Big Timer
                        Text(formatTime(timerModel.timeRemaining))
                            .font(.system(size: geometry.size.width * 0.35, weight: .bold, design: .monospaced)) // Width-based in portrait is safer? Or keep existing logic
                            .font(.system(size: geometry.size.height * 0.4, weight: .bold, design: .monospaced)) // Fallback to height ratio similar to before but tuned
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .padding(.horizontal)
                            .accessibilityIdentifier("TimerText")
                        
                        // Progress Bar
                        ProgressView(value: timerModel.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .scaleEffect(x: 1, y: 4, anchor: .center)
                            .padding()
                        
                        Spacer()
                        
                        // Controls
                        HStack(spacing: 50) {
                            Button(action: {
                                timerModel.stop()
                                withAnimation {
                                    isShowingTimer = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.white)
                            }
                            .accessibilityIdentifier("StopButton")
                            
                            Button(action: {
                                if timerModel.isPaused {
                                    timerModel.resume()
                                } else {
                                    timerModel.pause()
                                }
                            }) {
                                Image(systemName: timerModel.isPaused ? "play.circle.fill" : "pause.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.white)
                            }
                            .accessibilityIdentifier("PauseButton")
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
        }
    }
}
