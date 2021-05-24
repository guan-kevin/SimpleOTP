//
//  EnableiCloudView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/23/21.
//

import SwiftUI

struct EnableiCloudView: View {
    @EnvironmentObject var model: MainViewModel
    @ObservedObject var settingsModel: SettingsViewModel

    var body: some View {
        Group {
            Form {
                Section(header: Text("")) {
                    if settingsModel.enableiCloud {
                        Button(action: {
                            if self.settingsModel.disableiCloudSyncing() {
                                self.model.updateValet()
                            }
                        }) {
                            Text("Disable iCloud Syncing")
                        }
                    } else {
                        Button(action: {
                            if self.settingsModel.enableiCloudSyncing() {
                                self.model.updateValet()
                            }
                        }) {
                            Text("Enable iCloud Syncing")
                        }
                    }
                }
            }
            .alert(isPresented: $settingsModel.showAlert) {
                Alert(title: Text(self.settingsModel.alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                self.settingsModel.checkIfiCloudEnable()
            }
            .navigationBarTitle("iCloud Syncing", displayMode: .inline)
        }
    }
}
