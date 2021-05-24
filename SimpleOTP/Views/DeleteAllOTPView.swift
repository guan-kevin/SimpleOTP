//
//  DeleteAllOTPView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/18/21.
//

import LocalAuthentication
import SwiftUI
import Valet

struct DeleteAllOTPView: View {
    @State var showConfirm = false
    @EnvironmentObject var model: MainViewModel

    var body: some View {
        Form {
            Section(header: Text(""), footer: Text("All OTP will be deleted immediately. You can't undo this action.")) {
                Button(action: {
                    self.showConfirm = true
                }) {
                    Text("Delete All Data")
                        .foregroundColor(.red)
                }
            }
        }
        .actionSheet(isPresented: $showConfirm) {
            ActionSheet(title: Text("Are you sure you want to do this?"), buttons: [.destructive(Text("YES")) {
                deleteAllData()
            }, .cancel()])
        }
        .navigationBarTitle("", displayMode: .inline)
    }

    func deleteAllData() {
        let laContext = LAContext()
        let reason = "Remember, you can't undo this action!"
        laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
            if success {
                DispatchQueue.main.async {
                    let valet = UserDefaults.standard.bool(forKey: "useiCloud") ? Valet.iCloudSharedGroupValet(with: ValetControl.getSharedGroupIdentifier(), accessibility: .whenUnlocked) : Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
                    do {
                        try valet.removeObject(forKey: "otps")
                        self.model.otps = []

                        if UserDefaults.standard.bool(forKey: "enableWatchApp") {
                            self.model.provider.updateWatchInfo(otps: [])
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
