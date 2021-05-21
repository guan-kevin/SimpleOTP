//
//  SettingsView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/18/21.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var model: MainViewModel
    @StateObject var settingsModel = SettingsViewModel()

    @AppStorage("enableBiometrics") var enableBiometrics: Bool = false

    @State var tempWorkaroundUUID = UUID()

    var body: some View {
        Group {
            Form {
                Section(header: Text("")) {
                    Toggle("Enable " + (self.settingsModel.getBiometricType() ?? "Face ID / Touch ID"), isOn: $enableBiometrics)
                    NavigationLink(destination: EnableWatchAppView(settingsModel: settingsModel)) {
                        Text("Enable Watch App")
                    }
                }

                Section {
                    NavigationLink(destination: BackupDataView()) {
                        Text("Backup/Import All Data")
                    }
                    NavigationLink(destination: DeleteAllOTPView()) {
                        Text("Delete All Data")
                    }
                    .disabled(self.model.otps.count == 0)
                    Text("Info")
                }
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .id(tempWorkaroundUUID)
        .onDisappear {
            tempWorkaroundUUID = UUID() // otherwise form won't deselect
        }
    }
}
