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
                    .id(tempWorkaroundUUID)
                }

                Section {
                    NavigationLink(destination: BackupDataView()) {
                        Text("Backup/Import All Data")
                    }
                    .id(tempWorkaroundUUID)
                    NavigationLink(destination: DeleteAllOTPView()) {
                        Text("Delete All Data")
                    }
                    .id(tempWorkaroundUUID)
                    .disabled(self.model.otps.count == 0)
                    
                    NavigationLink(destination: InfoView()) {
                        Text("Acknowledgements")
                    }
                    .id(tempWorkaroundUUID)
                }
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .onDisappear {
            tempWorkaroundUUID = UUID() // otherwise form won't deselect
        }
    }
}
