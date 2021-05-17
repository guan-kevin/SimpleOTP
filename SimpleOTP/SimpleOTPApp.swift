//
//  SimpleOTPApp.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import SwiftUI

@main
struct SimpleOTPApp: App {
    @ObservedObject var model = MainViewModel()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .onChange(of: scenePhase, perform: { value in
                    switch value {
                    case .active:
                        if model.isAppLocked() {
                            model.unlockApp()
                        }
                    case .background:
                        model.isLocked = true
                    case .inactive:
                        break
                    @unknown default:
                        print("default state")
                    }
                })
                .onAppear {
                    model.unlockApp()
                }
        }
    }
}
