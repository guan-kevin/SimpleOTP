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
    @Published var enableiCloud = false
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

    func checkIfiCloudEnable() {
        self.enableiCloud = UserDefaults.standard.bool(forKey: "enableiCloud")
    }

    func enableWatchApp(password: String) -> Bool {
        guard password != "", password.count > 5 else {
            self.alertMessage = "Invalid Password"
            self.showAlert = true
            return false
        }
        let valet = UserDefaults.standard.bool(forKey: "useiCloud") ? Valet.iCloudValet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked) : Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
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
        let valet = UserDefaults.standard.bool(forKey: "useiCloud") ? Valet.iCloudValet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked) : Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
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

    func disableiCloudSyncing() -> Bool {
        guard self.enableiCloud == true else { return false }

        do {
            let icloud = Valet.iCloudValet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
            let local = Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)

            var iCloudOTPS: [OTP] = []
            var iCloudPassword: String?
            if let data = try? icloud.object(forKey: "otps") {
                iCloudOTPS = EncryptionHelper.decodeData(data: data, as: [OTP].self) ?? []
            }

            if let data = try? icloud.string(forKey: "password") {
                iCloudPassword = data
            }

            if iCloudOTPS.count > 0 {
                // override iPhone data

                if let data = EncryptionHelper.encodeData(iCloudOTPS) {
                    try local.setObject(data, forKey: "otps")
                    
                    print("\(iCloudOTPS.count) OTPs transfered to iPhone")

                    if iCloudPassword != nil {
                        try local.setString(iCloudPassword!, forKey: "password")
                        
                        print("1 Password transfered to iCloud")
                    }
                }
            }
        } catch {
            self.alertMessage = error.localizedDescription
            self.showAlert = true
            return false
        }

        self.enableiCloud = false
        UserDefaults.standard.set(false, forKey: "useiCloud")
        return true
    }

    func enableiCloudSyncing() -> Bool {
        guard self.enableiCloud == false else { return false }

        do {
            let icloud = Valet.iCloudValet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
            let local = Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)

            var localOTPS: [OTP] = []
            var localPassword: String?
            if let data = try? local.object(forKey: "otps") {
                localOTPS = EncryptionHelper.decodeData(data: data, as: [OTP].self) ?? []
            }

            if let data = try? local.string(forKey: "password") {
                localPassword = data
            }

            if localOTPS.count > 0 {
                // override iCloud data

                if let data = EncryptionHelper.encodeData(localOTPS) {
                    try icloud.setObject(data, forKey: "otps")
                    
                    print("\(localOTPS.count) OTPs transfered to iCloud")

                    if localPassword != nil {
                        try icloud.setString(localPassword!, forKey: "password")
                        
                        print("1 Password transfered to iCloud")
                    }
                }
            }
        } catch {
            self.alertMessage = error.localizedDescription
            self.showAlert = true
            return false
        }
        
        self.enableiCloud = true
        UserDefaults.standard.set(true, forKey: "useiCloud")
        return true
    }
}
