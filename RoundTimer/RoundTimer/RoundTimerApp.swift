//
//  RoundTimerApp.swift
//  RoundTimer
//
//  Created by Vadim Pospelov on 25.12.2025.
//

import SwiftUI
import CoreData

@main
struct RoundTimerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
