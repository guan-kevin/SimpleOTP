//
//  ContentView.swift
//  SimpleOTP WatchKit Extension
//
//  Created by Kevin Guan on 5/16/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: MainViewModel
    @State var showPasswordSheet = false
    @State var showDeleteSuccess = false
    let pub = NotificationCenter.default.publisher(for: NSNotification.Name("UserEnableWatchApp"))

    var body: some View {
        MainView()
            .onReceive(pub) { notification in
                print(notification)
                if let result = notification.userInfo {
                    print("has userInfo")
                    if let type = result["type"] as? Int {
                        print(type)
                        // 0: Disable, 1: Enable with Password, 2: Enabled
                        if type == 0 {
                            self.model.otps = []
                        } else if type == 1 {
                            self.showPasswordSheet = true
                        } else if type == 2 {
                            if let new = result["otps"] as? [OTP] {
                                self.model.otps = new
                            }
                        }
                        return
                    }
                }
            }
            .sheet(isPresented: $showPasswordSheet, onDismiss: {}) {
                SetPasswordView()
            }
            .alert(isPresented: $showDeleteSuccess) {
                Alert(title: Text("Deleted all your OTP data"), dismissButton: .default(Text("OK")))
            }
    }
}
