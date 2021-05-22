//
//  WatchConnectivityProvoder.swift
//  SimpleOTP WatchKit Extension
//
//  Created by Kevin Guan on 5/20/21.
//

import Foundation
import Valet
import WatchConnectivity

final class WatchConnectivityProvoder: NSObject, WCSessionDelegate {
    var session: WCSession?

    func startSession() {
        guard session == nil else { return }
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
        }
    }

    func updateiPhoneInfo(otps: [OTP]) {
        guard session != nil, session?.activationState == .activated else {
            print("Session is NULL")
            startSession()
            return
        }

        let valet = Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
        let password = try? valet.string(forKey: "password")

        guard password != nil else { return }

        let result = EncryptionHelper.encryptData(otps: otps, key: password!)

        guard result != nil else { return }

        do {
            try session!.updateApplicationContext(["otps": result!])
            print("Sent without Error!")
        } catch {
            print(error)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("activationDidCompleteWith")
        } else {
            print(error)
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        print("didReceiveApplicationContext")
        do {
            if let enable = applicationContext["enableWatchApp"] as? Bool {
                UserDefaults.standard.set(enable, forKey: "enableWatchApp")

                let valet = Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
                if !enable {
                    try? valet.removeObject(forKey: "otps")
                    try? valet.removeObject(forKey: "password")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("UserEnableWatchApp"), object: nil, userInfo: ["type": 0])
                    }
                } else {
                    if let otps = applicationContext["otps"] as? String {
                        if let password = try? valet.string(forKey: "password") {
                            if let result = EncryptionHelper.decryptData(data: otps, key: password) {
                                // Dont override if current counter is older

                                var watch_otps: [OTP] = []
                                if let data = try? valet.object(forKey: "otps") {
                                    watch_otps = EncryptionHelper.decodeData(data: data, as: [OTP].self) ?? []
                                }

                                var save_otps: [OTP] = []
                                for iPhone_otp in result {
                                    if iPhone_otp.type == .hotp {
                                        let searchID = watch_otps.filter {
                                            // Save OTP and watch one is more recent
                                            $0.id == iPhone_otp.id && $0.counter > iPhone_otp.counter
                                        }

                                        if searchID.count > 0 {
                                            save_otps.append(searchID.first!)
                                            continue
                                        }

                                    }
                                    
                                    save_otps.append(iPhone_otp)
                                }

                                if let data = EncryptionHelper.encodeData(save_otps) {
                                    try valet.setObject(data, forKey: "otps")
                                    try valet.setString(password, forKey: "password")

                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: Notification.Name("UserEnableWatchApp"), object: nil, userInfo: ["type": 2, "otps": save_otps])
                                    }
                                    return
                                }
                            }
                        }

                        try valet.setString(otps, forKey: "temp")
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("UserEnableWatchApp"), object: nil, userInfo: ["type": 1])
                        }
                    }
                }
            }
        } catch {}
    }
}
