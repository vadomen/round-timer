import SwiftUI

struct SettingsView: View {
    @ObservedObject var timerModel: RoundTimerModel
    @Binding var isShowingTimer: Bool
    
    // Internal state for converting TimeInterval to UI friendly Ints
    @State private var roundMinutes: Int = 2
    @State private var roundSeconds: Int = 0
    @State private var restMinutes: Int = 1
    @State private var restSeconds: Int = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configuration")) {
                    Stepper("Rounds: \(timerModel.totalRounds)", value: $timerModel.totalRounds, in: 1...20)
                }
                
                Section(header: Text("Round Duration")) {
                    HStack {
                        Picker("Min", selection: $roundMinutes) {
                            ForEach(0..<10) { Text("\($0) min").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        
                        Picker("Sec", selection: $roundSeconds) {
                            ForEach(stride(from: 0, to: 60, by: 5).map { $0 }, id: \.self) { i in
                                Text("\(i) s").tag(i)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
                
                Section(header: Text("Rest Duration")) {
                    HStack {
                        Picker("Min", selection: $restMinutes) {
                            ForEach(0..<10) { Text("\($0) min").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        
                        Picker("Sec", selection: $restSeconds) {
                            ForEach(stride(from: 0, to: 60, by: 5).map { $0 }, id: \.self) { i in
                                Text("\(i) s").tag(i)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
                
                Section {
                    Button(action: startTimer) {
                        HStack {
                            Spacer()
                            Text("Start Workout")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Round Timer")
        }
    }
    
    private func startTimer() {
        // Update model
        timerModel.workDuration = TimeInterval(roundMinutes * 60 + roundSeconds)
        timerModel.restDuration = TimeInterval(restMinutes * 60 + restSeconds)
        
        timerModel.start()
        withAnimation {
            isShowingTimer = true
        }
    }
}
