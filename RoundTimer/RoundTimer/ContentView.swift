import SwiftUI

struct ContentView: View {
    @StateObject private var timerModel = RoundTimerModel()
    @State private var isShowingTimer = false
    
    var body: some View {
        ZStack {
            if isShowingTimer {
                TimerView(timerModel: timerModel, isShowingTimer: $isShowingTimer)
                    .transition(.move(edge: .bottom))
            } else {
                SettingsView(timerModel: timerModel, isShowingTimer: $isShowingTimer)
            }
        }
        .animation(.default, value: isShowingTimer)
    }
}
