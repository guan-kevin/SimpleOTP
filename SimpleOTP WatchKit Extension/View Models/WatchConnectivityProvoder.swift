//
//  WatchConnectivityProvoder.swift
//  SimpleOTP WatchKit Extension
//
//  Created by Kevin Guan on 5/20/21.
//

import Foundation
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
    
    func fetch() {
        print(session?.receivedApplicationContext)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("didReceiveApplicationContext")
        print(applicationContext)
    }
}
