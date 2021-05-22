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
        print("INIT")
        valet = Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
//        try! valet?.removeAllObjects()
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

    func userEnteredPassword(password: String) -> (success: Bool, reason: String) {
        if valet != nil {
            do {
                let temp = try valet?.string(forKey: "temp")
                if temp == nil {
                    return (success: false, reason: "Temp is nil")
                }
                if let result = EncryptionHelper.decryptData(data: temp!, key: password) {
                    otps = result
                    if let data = EncryptionHelper.encodeData(result) {
                        try valet?.setObject(data, forKey: "otps")
                        try valet?.setString(password, forKey: "password")
                        return (success: true, reason: "Done")
                    }
                    return (success: false, reason: "Can't encode data")
                }
                return (success: false, reason: "Can't decrypt data")
            } catch {
                return (success: false, reason: error.localizedDescription)
            }
        }
        return (success: false, reason: "valet is nil")
    }
}
