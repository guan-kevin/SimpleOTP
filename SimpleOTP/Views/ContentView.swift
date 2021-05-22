//
//  ContentView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: MainViewModel
    let pub = NotificationCenter.default.publisher(for: NSNotification.Name("WatchAppSyncing"))

    var body: some View {
        Group {
            if model.isAppLocked() {
                LockView()
            } else {
                MainView()
            }
        }
        .onReceive(pub) { notification in
            print("Update")
            if let result = notification.userInfo {
                if let new = result["otps"] as? [OTP] {
                    self.model.otps = new
                    print("Success")
                }
            }
        }
    }
}
