//
//  MainView.swift
//  SimpleOTP Mac App
//
//  Created by Kevin Guan on 5/23/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var model: MainViewModel
    @State var date = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            if model.otps.count == 0 {
                Text("No OTP Yet!")
                Text("You can add one from the iPhone app, then enable iCloud Syncing")
                    .multilineTextAlignment(.center)
            } else {
                List {
                    ForEach(self.model.otps) { otp in
                        OTPRowView(otp: otp, date: $date)
                    }
                }
                .listStyle(SidebarListStyle())
            }

            HStack {
                Spacer()

                Button(action: {
                    NSApplication.shared.terminate(self)
                }) {
                    Label("Quit", systemImage: "xmark.circle")
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Button(action: {
                    self.model.list()
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise.circle")
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
            .padding()
        }
        .onAppear {
            self.model.list()
        }
        .onReceive(timer) { result in
            if Int(result.timeIntervalSince1970) % 15 == 0 {
                self.model.list()
            }
            withAnimation {
                date = result
            }
        }
    }
}
