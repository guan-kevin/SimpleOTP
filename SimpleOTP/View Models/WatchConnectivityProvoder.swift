//
//  WatchConnectivityProvoder.swift
//  SimpleOTP
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

    func updateWatchInfo(otps: [OTP]) {
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
            try session!.updateApplicationContext(["enableWatchApp": true, "otps": result!])
            print("Sent without Error!")
        } catch {
            print(error.localizedDescription)
        }
    }

    func disableWatchApp() {
        guard session != nil, session?.activationState == .activated else {
            print("Session is NULL")
            startSession()
            return
        }

        do {
            try session!.updateApplicationContext(["enableWatchApp": false, "otps": []])
            print("Sent without Error!")
        } catch {
            print(error.localizedDescription)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("activationDidCompleteWith")
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        print("didReceiveApplicationContext")
        let valet = Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)

        do {
            if let otps = applicationContext["otps"] as? String {
                if let password = try? valet.string(forKey: "password") {
                    if let result = EncryptionHelper.decryptData(data: otps, key: password) {
                        // Dont override if current counter is older

                        var iPhone_otps: [OTP] = []
                        if let data = try? valet.object(forKey: "otps") {
                            iPhone_otps = EncryptionHelper.decodeData(data: data, as: [OTP].self) ?? []
                        }

                        let watch_hotps = result.filter { $0.type == .hotp } // get all hotps from watch

                        for watch_hotp in watch_hotps {
                            for i in 0 ..< iPhone_otps.count {
                                if watch_hotp.id == iPhone_otps[i].id && watch_hotp.counter > iPhone_otps[i].counter {
                                    // watch has newer HOTP
                                    iPhone_otps[i].counter = watch_hotp.counter
                                }
                            }
                        }

                        if let data = EncryptionHelper.encodeData(iPhone_otps) {
                            try valet.setObject(data, forKey: "otps")

                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("WatchAppSyncing"), object: nil, userInfo: ["otps": iPhone_otps])
                            }
                            return
                        }
                    }
                }
            }
        } catch {}
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
}
