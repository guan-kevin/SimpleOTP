//
//  SettingsViewModel.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/18/21.
//

import Foundation
import LocalAuthentication
import Valet

final class SettingsViewModel: ObservableObject {
    @Published var enableWatchApp = false
    @Published var showAlert = false
    @Published var alertMessage = ""

    func getBiometricType() -> String? {
        let laContext = LAContext()

        var error: NSError?
        guard laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return nil
        }

        if laContext.biometryType == .faceID {
            return "Face ID"
        } else {
            return "Touch ID"
        }
    }

    func checkIfWatchAppEnable() {
        self.enableWatchApp = UserDefaults.standard.bool(forKey: "enableWatchApp")
    }

    func enableWatchApp(password: String) -> Bool {
        guard password != "", password.count > 5 else {
            self.alertMessage = "Invalid Password"
            self.showAlert = true
            return false
        }
        let valet = Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
        do {
            try valet.setString(password, forKey: "password")
            UserDefaults.standard.set(true, forKey: "enableWatchApp")
            self.enableWatchApp = true

            self.alertMessage = "Success. Now open the Apple Watch app to complete the process!"
            self.showAlert = true
            return true
        } catch {
            self.alertMessage = "Unable to store your password, please tray again later."
            self.showAlert = true
            return false
        }
    }

    func disableWatchApp() -> Bool {
        let valet = Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
        do {
            try valet.removeObject(forKey: "password")
            UserDefaults.standard.set(false, forKey: "enableWatchApp")
            self.enableWatchApp = false

            self.alertMessage = "Success. Now open the Apple Watch app to complete the process!"
            self.showAlert = true
            return true
        } catch {
            self.alertMessage = "Unable to delete your password, please tray again later."
            self.showAlert = true
            return false
        }
    }
}
