//
//  MainViewModel.swift
//  SimpleOTP WatchKit Extension
//
//  Created by Kevin Guan on 5/20/21.
//

import Valet
import WatchKit

final class MainViewModel: ObservableObject {
    var valet: Valet?
    @Published var otps: [OTP] = []

    var provider: WatchConnectivityProvoder!

    init() {
        valet = Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
        list()

        provider = WatchConnectivityProvoder()
        provider.startSession()
    }

    func list() {
        if valet != nil {
            if let data = try? valet!.object(forKey: "otps") {
                otps = EncryptionHelper.decodeData(data: data, as: [OTP].self) ?? []
            }
        }
    }

    func saveAllOTPs() {
        if valet != nil {
            do {
                if let data = EncryptionHelper.encodeData(otps) {
                    try valet?.setObject(data, forKey: "otps")

                    provider.updateiPhoneInfo(otps: otps)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func userEnteredPassword(password: String) -> (success: Bool, reason: String) {
        if valet != nil {
            do {
                let temp = try valet?.string(forKey: "temp")
                if temp == nil {
                    return (success: false, reason: "Unable to find the encrypted data")
                }
                if let result = EncryptionHelper.decryptData(data: temp!, key: password) {
                    otps = result
                    if let data = EncryptionHelper.encodeData(result) {
                        try valet?.setObject(data, forKey: "otps")
                        try valet?.setString(password, forKey: "password")
                        return (success: true, reason: "Done")
                    }
                    return (success: false, reason: "Unable to encode OTP data")
                }
                return (success: false, reason: "Can't decrypt data, perhaps the password is incorrect")
            } catch {
                return (success: false, reason: error.localizedDescription)
            }
        }
        return (success: false, reason: "Valet is not available")
    }
}
