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
        valet = UserDefaults.standard.bool(forKey: "useiCloud") ? Valet.iCloudSharedGroupValet(with: ValetControl.getSharedGroupIdentifier(), accessibility: .whenUnlocked) : Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)

        provider = WatchConnectivityProvoder()
        provider.startSession()
        
        list(sync: false)
    }

    func updateValet() {
        valet = UserDefaults.standard.bool(forKey: "useiCloud") ? Valet.iCloudSharedGroupValet(with: ValetControl.getSharedGroupIdentifier(), accessibility: .whenUnlocked) : Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
    }

    func list(sync: Bool = false) {
        if valet != nil {
            if let data = try? valet!.object(forKey: "otps") {
                let temp = EncryptionHelper.decodeData(data: data, as: [OTP].self) ?? []

                if sync, UserDefaults.standard.bool(forKey: "useiCloud") {
                    if otps != temp, otps != [] {
                        if UserDefaults.standard.bool(forKey: "enableWatchApp") {
                            if provider.session?.activationState != .activated {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    self.provider.updateWatchInfo(otps: temp)
                                }
                            } else {
                                provider.updateWatchInfo(otps: temp)
                            }
                        }
                    }
                }

                otps = temp
            }
        }
    }

    func checkIfExists(otp: OTP) -> Bool {
        return otps.filter { $0.secret == otp.secret && $0.type == otp.type && $0.encryptions == otp.encryptions && $0.digits == otp.digits && $0.period == otp.period && $0.counter == otp.counter }.count > 0
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
        return isLocked && ValetControl.getEnableBiometrics()
    }

    func unlockApp() {
        guard isLocked, ValetControl.getEnableBiometrics() else { return }

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
