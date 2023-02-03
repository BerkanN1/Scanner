//
//  ScannerApp.swift
//  Scanner
//
//  Created by BERKAN NALBANT on 14.01.2023.
//

import SwiftUI

@main
struct ScannerApp: App {
    
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.conteiner.viewContext)
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase{
                
            case .background:
                print("Scene is in background")
                persistenceController.save()
            case .inactive:
                print("Scene is inactive")
            case .active:
                print("Scene is active")
            @unknown default:
                print("ERROR!!!!")
            }
        }
    }
}
