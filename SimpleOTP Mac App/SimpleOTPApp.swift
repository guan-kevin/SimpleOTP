//
//  SimpleOTP.swift
//  SimpleOTP Mac App
//
//  Created by Kevin Guan on 5/23/21.
//

import SwiftUI

@main
struct SimpleOTPApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            Text("Hello World?")
        }
    }
}
