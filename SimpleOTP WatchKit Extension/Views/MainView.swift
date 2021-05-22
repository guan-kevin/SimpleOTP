//
//  MainView.swift
//  SimpleOTP WatchKit Extension
//
//  Created by Kevin Guan on 5/21/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var model: MainViewModel
    @State var date = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        Group {
            if model.otps.count > 0 {
                List {
                    ForEach(model.otps) { otp in
                        OTPRowView(otp: otp, date: $date)
                    }
                }
                .listStyle(CarouselListStyle())
                .onReceive(timer) { result in
                    withAnimation {
                        date = result
                    }
                }
            } else {
                VStack {
                    Text("No OTP Yet!")
                    Text("You can add one from the iPhone app")
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}
