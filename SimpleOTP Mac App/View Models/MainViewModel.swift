//
//  MainViewModel.swift
//  SimpleOTP Mac App
//
//  Created by Kevin Guan on 5/23/21.
//

import Foundation
import SwiftUI
import Valet

final class MainViewModel: ObservableObject {
    var valet: Valet?

    @Published var otps: [OTP] = []

    var timer: Timer?

    @Published var date = Date()

    init() {
        print("INIT")
        valet = Valet.iCloudSharedGroupValet(with: ValetControl.getSharedGroupIdentifier(), accessibility: .whenUnlocked)
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
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    @objc func updateTime() {
        withAnimation {
            date = Date()
        }

        if Int(date.timeIntervalSince1970) % 15 == 0 {
            list()
        }
    }

    func startTimer() {
        guard timer == nil else { return }

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
