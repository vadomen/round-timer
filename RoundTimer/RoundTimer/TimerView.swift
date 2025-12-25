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
        case .idle:
            return Color.gray
        }
    }
    
    var statusText: String {
        switch timerModel.phase {
        case .work: return "ROUND \(timerModel.currentRound)"
        case .rest: return "REST"
        case .idle: return "READY"
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut, value: backgroundColor)
            
            VStack(spacing: 40) {
                // Header
                Text(statusText)
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                Spacer()
                
                // Big Timer
                Text(formatTime(timerModel.timeRemaining))
                    .font(.system(size: 90, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)
                
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
                }
                .padding(.bottom, 50)
            }
        }
    }
}
