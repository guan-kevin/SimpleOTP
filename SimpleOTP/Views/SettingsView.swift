//
//  SettingsView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/18/21.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var model: MainViewModel
    @ObservedObject var settingsModel = SettingsViewModel()

    @AppStorage("enableBiometrics") var enableBiometrics: Bool = false

    @State var tempWorkaroundUUID = UUID()

    var body: some View {
        //  Group {
        Form {
            NavigationLink(destination: ReorderOTPView()) {
                Text("Reorder OTP List")
            }
            .disabled(self.model.otps.count == 0)

            Section {
                Toggle("Enable " + (self.settingsModel.getBiometricType() ?? "Face ID / Touch ID"), isOn: $enableBiometrics)
                Text("Enable Watch App")
            }

            Section {
                Text("Backup All Data")
                NavigationLink(destination: DeleteAllOTPView()) {
                    Text("Delete All Data")
                }
                .disabled(self.model.otps.count == 0)
                Text("Info")
            }
        }
        //  }
        .navigationBarTitle("Settings", displayMode: .inline)
        .id(tempWorkaroundUUID)
        .onDisappear {
            tempWorkaroundUUID = UUID() // otherwise form won't deselect
        }
    }
}
