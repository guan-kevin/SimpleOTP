//
//  SetPasswordView.swift
//  SimpleOTP WatchKit Extension
//
//  Created by Kevin Guan on 5/21/21.
//

import SwiftUI

struct SetPasswordView: View {
    @State var password = ""
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var model: MainViewModel

    @State var message = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("To decrypt your OTP data, you need to enter the password you set on your iPhone first")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.headline)

                SecureField("Password", text: $password)

                Button(action: {
                    let result = self.model.userEnteredPassword(password: password)
                    if result.success {
                        self.presentation.wrappedValue.dismiss()
                    } else {
                        self.message = result.reason
                    }
                }) {
                    Text("Decrypt Data")
                }

                if message != "" {
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
        }
    }
}
