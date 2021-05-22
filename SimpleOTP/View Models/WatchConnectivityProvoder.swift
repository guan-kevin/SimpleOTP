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
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("didReceiveApplicationContext")
        print(applicationContext)
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
            print(error)
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
            print(error)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("activationDidCompleteWith")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
}
