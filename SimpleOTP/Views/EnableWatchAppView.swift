//
//  EnableWatchAppView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/19/21.
//

import SwiftUI

struct EnableWatchAppView: View {
    @EnvironmentObject var model: MainViewModel
    @ObservedObject var settingsModel: SettingsViewModel

    @State var showEnableView = false
    @State var passwordText = ""

    var body: some View {
        Group {
            Form {
                Section(header: Text(""), footer: Text(showEnableView ? "To enable syncing with your Apple Watch, you need to set a password first. Your password should have more than 5 characters." : "")) {
                    if settingsModel.enableWatchApp {
                        Button(action: {
                            if self.settingsModel.disableWatchApp() {
                                self.model.provider.disableWatchApp()
                            }
                        }) {
                            Text("Disable Watch App")
                        }
                    } else {
                        Button(action: {
                            withAnimation {
                                self.showEnableView = true
                            }
                        }) {
                            Text("Enable Watch App")
                        }
                        .disabled(showEnableView)

                        if showEnableView {
                            SecureField("Password", text: $passwordText)

                            Button(action: {
                                if self.settingsModel.enableWatchApp(password: passwordText) {
                                    print("YES")

                                    self.showEnableView = false

                                    self.model.provider.updateWatchInfo(otps: model.otps)
                                }
                            }) {
                                Text("Confirm")
                            }
                            .disabled(passwordText.count <= 5)
                        }
                    }
                }

                Button(action: {
                    print(self.model.provider.session?.isReachable)
                }) {
                    Text("TEST")
                }
            }
            .alert(isPresented: $settingsModel.showAlert) {
                Alert(title: Text(self.settingsModel.alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                self.settingsModel.checkIfWatchAppEnable()
            }
            .navigationBarTitle("Apple Watch", displayMode: .inline)
        }
    }
}
