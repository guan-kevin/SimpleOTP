//
//  SimpleOTPApp.swift
//  SimpleOTP WatchKit Extension
//
//  Created by Kevin Guan on 5/16/21.
//

import SwiftUI

@main
struct SimpleOTPApp: App {
    
    @ObservedObject var model = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(model)
            }
        }
    }
}
