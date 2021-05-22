//
//  MainView.swift
//  SimpleOTP WatchKit Extension
//
//  Created by Kevin Guan on 5/21/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var model: MainViewModel
    var body: some View {
        Group {
            if model.otps.count > 0 {
                List {
                    ForEach(model.otps) { otp in
                        Text(otp.accountname)
                    }
                }
            } else {
                Text("No OTP Yet!")
            }
        }
    }
}
