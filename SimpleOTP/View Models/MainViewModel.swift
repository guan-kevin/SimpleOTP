//
//  MainViewModel.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import Foundation
import LocalAuthentication
import Valet

final class MainViewModel: ObservableObject {
    @Published var isLocked = true

    var valet: Valet?
    @Published var otps: [OTP] = []

    var provider: WatchConnectivityProvoder!

    init() {
        print("INIT")
        valet = UserDefaults.standard.bool(forKey: "useiCloud") ? Valet.iCloudValet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked) : Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
        list()

        provider = WatchConnectivityProvoder()
        provider.startSession()
    }

    func updateValet() {
        valet = UserDefaults.standard.bool(forKey: "useiCloud") ? Valet.iCloudValet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked) : Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
    }

    func list() {
        if valet != nil {
            if let data = try? valet!.object(forKey: "otps") {
                otps = EncryptionHelper.decodeData(data: data, as: [OTP].self) ?? []
            }
        }
    }

    func addOTP(otp: OTP) {
        otps.append(otp)
        saveAllOTPs()
    }

    func saveAllOTPs() {
        if valet != nil {
            do {
                if let data = EncryptionHelper.encodeData(otps) {
                    try valet?.setObject(data, forKey: "otps")

                    if UserDefaults.standard.bool(forKey: "enableWatchApp") {
                        provider.updateWatchInfo(otps: otps)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func isAppLocked() -> Bool {
        return isLocked && UserDefaults.standard.bool(forKey: "enableBiometrics")
    }

    func unlockApp() {
        guard isLocked, UserDefaults.standard.bool(forKey: "enableBiometrics") else { return }

        let laContext = LAContext()
        let reason = "Unlock SimpleOTP"
        laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.isLocked = false
                }
            } else {
                if let error = error as? LAError {
                    DispatchQueue.main.async {
                        print(error.localizedDescription)

                        if error.code == .biometryLockout || error.code == .biometryNotEnrolled || error.code == .biometryNotAvailable {
                            // try again without biometrics

                            laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                                if success {
                                    DispatchQueue.main.async {
                                        self.isLocked = false
                                    }
                                } else {
                                    print("Not able to open the app anymore!")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
