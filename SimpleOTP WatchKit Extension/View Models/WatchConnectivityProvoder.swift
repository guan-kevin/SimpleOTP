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
                                if let data = EncryptionHelper.encodeData(result) {
                                    try valet.setObject(data, forKey: "otps")
                                    try valet.setString(password, forKey: "password")

                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: Notification.Name("UserEnableWatchApp"), object: nil, userInfo: ["type": 2, "otps": result])
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
